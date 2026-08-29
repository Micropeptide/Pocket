import SwiftUI
import AppKit

/// Pocket normally has no Dock icon. While Settings is open it temporarily gets
/// one via WindowPolicyCoordinator, same as HiddenIconsPanelController — the two
/// are reference-counted together so closing one doesn't hide the Dock icon while
/// the other is still open.
@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?

    func show() {
        WindowPolicyCoordinator.windowDidOpen()

        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hosting = NSHostingController(rootView: SettingsView())
        let newWindow = NSWindow(contentViewController: hosting)
        newWindow.title = "Pocket Settings"
        newWindow.styleMask = [.titled, .closable, .miniaturizable]
        newWindow.setContentSize(NSSize(width: 460, height: 420))
        newWindow.center()
        newWindow.delegate = self
        newWindow.isReleasedWhenClosed = false
        window = newWindow
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
        WindowPolicyCoordinator.windowDidClose()
    }
}
