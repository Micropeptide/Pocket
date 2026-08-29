import SwiftUI
import AppKit

/// Pocket's core window: a live list of every app's menu-bar icon, built via AX
/// independent of whether Control Center currently renders a given one on screen.
/// Clicking an entry opens it with AXUIElementPerformAction(kAXPressAction), which
/// works regardless of on-screen placement — see StatusItemController's header for
/// why that matters more than it sounds like it should on this era of macOS.
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

    /// Fires with `true` right after the panel opens and `false` right after it
    /// closes — lets AutoHideController/FullscreenObserver arm/disarm without
    /// depending on StatusItemController, which no longer tracks any state of its
    /// own now that there's no separate hide/show mechanism.
    var onVisibilityChanged: ((Bool) -> Void)?

    var isOpen: Bool { window?.isVisible ?? false }

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
        onVisibilityChanged?(true)

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
        onVisibilityChanged?(false)
    }
}
