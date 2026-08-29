import AppKit
import ApplicationServices

enum MenuBarZone: String, Equatable {
    case alwaysVisible
    case hidden
}

/// One running app's menu-bar status item, as discovered by MenuBarInventory's AX
/// walk. `axElement` lets Pocket's panel trigger the item's own click behavior via
/// AXUIElementPerformAction(kAXPressAction) — proven reliable in testing, and the
/// only dependable way to reach an item Control Center itself has decided not to
/// render on screen (see README's "why a panel, not just hide/show" note).
struct MenuBarIconInfo: Identifiable {
    var id: String { "\(ownerPID)-\(Int(screenX))" }

    let appName: String
    let appIcon: NSImage?
    let ownerPID: pid_t
    let screenX: CGFloat
    let zone: MenuBarZone
    let axElement: AXUIElement

    func press() {
        AXUIElementPerformAction(axElement, kAXPressAction as CFString)
    }
}
