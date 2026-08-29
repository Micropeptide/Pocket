import AppKit
import ApplicationServices

/// One running app's menu-bar status item, as discovered by MenuBarInventory's AX
/// walk. `axElement` lets Pocket's panel trigger the item's own click behavior via
/// AXUIElementPerformAction(kAXPressAction) — the reliable way to reach it
/// regardless of whether Control Center currently renders it on screen.
struct MenuBarIconInfo: Identifiable {
    var id: String { "\(ownerPID)-\(Int(screenX))" }

    let appName: String
    let appIcon: NSImage?
    let ownerPID: pid_t
    let screenX: CGFloat
    let axElement: AXUIElement

    func press() {
        AXUIElementPerformAction(axElement, kAXPressAction as CFString)
    }
}
