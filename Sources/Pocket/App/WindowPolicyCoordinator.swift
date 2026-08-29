import AppKit

/// Pocket normally has no Dock icon (menu-bar-only accessory app). Whenever any of
/// its windows is open it should behave like a normal app — Dock icon, Cmd-Tab
/// visible — and go back to menu-bar-only once every window is closed. Both
/// HiddenIconsPanelController and SettingsWindowController can have a window open
/// at the same time, so activation policy is reference-counted here rather than
/// each controller setting it independently (which would let one controller's
/// close prematurely hide the Dock icon while the other's window is still open).
@MainActor
enum WindowPolicyCoordinator {
    private static var openWindowCount = 0

    static func windowDidOpen() {
        openWindowCount += 1
        NSApp.setActivationPolicy(.regular)
    }

    static func windowDidClose() {
        openWindowCount = max(0, openWindowCount - 1)
        if openWindowCount == 0 {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
