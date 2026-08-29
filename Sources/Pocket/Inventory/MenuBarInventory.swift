import AppKit
import ApplicationServices

/// Walks every running app's `AXExtrasMenuBar` (the private-but-widely-used AX
/// attribute for an app's status-bar items) to build a live list of menu-bar
/// icons. Deliberately independent of whether Control Center actually renders a
/// given icon on screen — see StatusItemController's header comment for why that
/// distinction matters on this era of macOS.
///
/// Deliberately NOT @MainActor: each AXUIElementCopyAttributeValue call is a
/// synchronous cross-process round trip, and with dozens of running apps that adds
/// up to real, user-visible wall-clock time — calling this from a background
/// queue (see HiddenIconsPanelModel.refresh) is what keeps the window responsive.
enum MenuBarInventory {

    static func fetch() -> [MenuBarIconInfo] {
        let currentPID = ProcessInfo.processInfo.processIdentifier
        var icons: [MenuBarIconInfo] = []

        for app in NSWorkspace.shared.runningApplications where app.processIdentifier != currentPID {
            guard let children = extrasMenuBarChildren(for: app.processIdentifier), !children.isEmpty else { continue }

            for child in children {
                guard let x = positionX(of: child) else { continue }
                icons.append(MenuBarIconInfo(
                    appName: app.localizedName ?? "Unknown",
                    appIcon: app.icon,
                    ownerPID: app.processIdentifier,
                    screenX: x,
                    axElement: child
                ))
            }
        }

        return icons.sorted { $0.appName.localizedCaseInsensitiveCompare($1.appName) == .orderedAscending }
    }

    private static func extrasMenuBarChildren(for pid: pid_t) -> [AXUIElement]? {
        let axApp = AXUIElementCreateApplication(pid)
        var value: AnyObject?
        guard AXUIElementCopyAttributeValue(axApp, "AXExtrasMenuBar" as CFString, &value) == .success,
              let extras = value else { return nil }
        var children: AnyObject?
        guard AXUIElementCopyAttributeValue(extras as! AXUIElement, kAXChildrenAttribute as CFString, &children) == .success else { return nil }
        return children as? [AXUIElement]
    }

    private static func positionX(of element: AXUIElement) -> CGFloat? {
        var value: AnyObject?
        guard AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &value) == .success,
              let axValue = value else { return nil }
        var point = CGPoint.zero
        guard AXValueGetValue((axValue as! AXValue), .cgPoint, &point) else { return nil }
        return point.x
    }
}
