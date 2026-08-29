import AppKit

/// Owns Pocket's single menu bar item. Clicking it opens (or, if already open,
/// closes) HiddenIconsPanelController — the list of every app's menu-bar icon,
/// built via AX and opened with AXUIElementPerformAction(kAXPressAction). That
/// works regardless of whether Control Center currently renders a given icon on
/// screen, which is what makes it reliable rather than the classic "grow a spacer
/// to push icons off" trick other menu-bar managers use: on this era of macOS
/// every menu-bar item is hosted out-of-process by Control Center, which runs its
/// own opaque overflow/priority system that a spacer's length doesn't reliably
/// control (verified empirically, not assumed).
@MainActor
final class StatusItemController {

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    var onOpenSettings: (() -> Void)?
    var onOpenInventory: (() -> Void)?
    var onQuit: (() -> Void)?

    init() {
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(clicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.toolTip = "Pocket — click to see every menu bar icon"
        let image = NSImage(systemSymbolName: "square.grid.2x2", accessibilityDescription: "Show every menu bar icon")
        image?.isTemplate = true
        button.image = image
    }

    @objc private func clicked(_ sender: Any?) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showMenu()
        } else {
            onOpenInventory?()
        }
    }

    // MARK: Menu

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: "Show Menu Bar Icons…", action: #selector(menuOpenInventory), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Settings…", action: #selector(menuOpenSettings), keyEquivalent: ",").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Pocket", action: #selector(menuQuit), keyEquivalent: "q").target = self

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func menuOpenInventory() { onOpenInventory?() }
    @objc private func menuOpenSettings() { onOpenSettings?() }
    @objc private func menuQuit() { onQuit?() }
}
