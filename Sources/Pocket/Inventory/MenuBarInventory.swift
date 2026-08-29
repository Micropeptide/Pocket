import AppKit
import ApplicationServices

/// Walks every running app's `AXExtrasMenuBar` (the private-but-widely-used AX
/// attribute for an app's status-bar items) to build a live list of menu-bar icons,
/// classified against Pocket's own spacer position.
///
/// This is deliberately independent of whether Control Center actually renders an
/// icon on screen: on this macOS version Control Center hosts every item and runs
/// its own opaque overflow/priority system that doesn't reliably respond to the
/// classic "grow a spacer" trick (verified empirically — see StatusItemController's
/// header). AX position + AXUIElementPerformAction(kAXPressAction) work reliably
/// regardless, which is why the Inventory panel — not the raw menu bar — is Pocket's
/// primary way of reaching hidden-zone icons.
enum MenuBarInventory {

    struct Result {
        let icons: [MenuBarIconInfo]
        let spacerMinX: CGFloat?
    }

    @MainActor
    static func fetch() -> Result {
        let currentPID = ProcessInfo.processInfo.processIdentifier
        var icons: [MenuBarIconInfo] = []
        var spacerMinX: CGFloat?

        for app in NSWorkspace.shared.runningApplications {
            guard let children = extrasMenuBarChildren(for: app.processIdentifier), !children.isEmpty else { continue }

            if app.processIdentifier == currentPID {
                // Pocket's own items, created [toggle, spacer] in that order —
                // only the spacer's X is needed, to classify everyone else.
                if children.count >= 2, let x = positionX(of: children[1]) {
                    spacerMinX = x
                }
                continue
            }

            for child in children {
                guard let x = positionX(of: child) else { continue }
                icons.append(MenuBarIconInfo(
                    appName: app.localizedName ?? "Unknown",
                    appIcon: app.icon,
                    ownerPID: app.processIdentifier,
                    screenX: x,
                    zone: .alwaysVisible, // reclassified below once spacerMinX is known
                    axElement: child
                ))
            }
        }

        let classified: [MenuBarIconInfo]
        if let spacerMinX {
            classified = icons.map { icon in
                MenuBarIconInfo(
                    appName: icon.appName,
                    appIcon: icon.appIcon,
                    ownerPID: icon.ownerPID,
                    screenX: icon.screenX,
                    zone: ZoneClassifier.classify(iconX: icon.screenX, spacerMinX: spacerMinX),
                    axElement: icon.axElement
                )
            }
        } else {
            classified = icons
        }

        return Result(icons: classified.sorted { $0.screenX < $1.screenX }, spacerMinX: spacerMinX)
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
