import SwiftUI
import AppKit

/// Pocket's primary way of reaching hidden-zone icons. On this era of macOS, Control
/// Center hosts every menu-bar item and runs its own opaque overflow/priority system
/// that doesn't reliably respond to the classic "grow a spacer" trick — verified
/// empirically, not assumed (see StatusItemController's header comment). This panel
/// sidesteps that entirely: it lists every app's menu-bar item via AX, independent of
/// whether Control Center currently renders it, and opens one on click via
/// AXUIElementPerformAction(kAXPressAction) — which works regardless of on-screen
/// placement.
///
/// Pocket normally has no Dock icon (menu-bar-only accessory app). While this panel is
/// open it temporarily gets one, so it behaves like a normal window; the icon goes away
/// again once the panel closes.
@MainActor
final class HiddenIconsPanelController: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let model = HiddenIconsPanelModel()

    var onOpenSettings: (() -> Void)? {
        get { model.onOpenSettings }
        set { model.onOpenSettings = newValue }
    }

    func toggle() {
        if let window, window.isVisible {
            window.close()
        } else {
            show()
        }
    }

    func close() {
        window?.close()
    }

    func show() {
        model.refresh()
        WindowPolicyCoordinator.windowDidOpen()
        NSApp.activate(ignoringOtherApps: true)

        if let window {
            raise(window)
            return
        }

        let hosting = NSHostingController(rootView: HiddenIconsView(model: model))
        let newWindow = NSWindow(contentViewController: hosting)
        newWindow.title = "Pocket"
        newWindow.styleMask = [.titled, .closable]
        newWindow.center()
        newWindow.delegate = self
        newWindow.isReleasedWhenClosed = false
        // Floating so it can't get buried behind other windows fighting for
        // topmost placement — this is a quick utility panel, not a document window.
        newWindow.level = .floating
        newWindow.collectionBehavior = [.moveToActiveSpace]
        window = newWindow
        raise(newWindow)
    }

    /// `makeKeyAndOrderFront` can be silently denied when the calling context isn't
    /// treated as a fresh user-initiated activation (observed during testing via a
    /// synthetic AXUIElementPerformAction trigger — the window was created with valid
    /// bounds but never actually composited on screen). `orderFrontRegardless` forces
    /// it to the front of its level unconditionally, then `makeKey` focuses it.
    private func raise(_ window: NSWindow) {
        window.orderFrontRegardless()
        window.makeKey()
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
        WindowPolicyCoordinator.windowDidClose()
    }
}
