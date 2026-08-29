import AppKit
import CoreGraphics

/// Best-effort detection of "the frontmost app is in a fullscreen Space", used to
/// auto-collapse hidden icons so they don't clutter a fullscreen app's own chrome.
///
/// There is no clean, fully-public API for "is the current Space fullscreen" (the
/// private CGSCopyManagedDisplaySpaces family does this but is deliberately not
/// used here). The heuristic below — does the frontmost app own an on-screen,
/// normal-layer window whose bounds match the full screen — is public-API-only and
/// good enough for its purpose, but can misfire for maximized-but-not-fullscreen
/// windows on some apps. Treated as best-effort everywhere it's surfaced in the UI.
@MainActor
final class FullscreenObserver {

    var onChange: ((Bool) -> Void)?

    private var isCurrentlyFullscreen = false

    init() {
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(self, selector: #selector(recheck), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
        center.addObserver(self, selector: #selector(recheck), name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    @objc private func recheck() {
        let fullscreen = Self.frontmostAppIsFullscreen()
        guard fullscreen != isCurrentlyFullscreen else { return }
        isCurrentlyFullscreen = fullscreen
        onChange?(fullscreen)
    }

    private static func frontmostAppIsFullscreen() -> Bool {
        guard let frontPID = NSWorkspace.shared.frontmostApplication?.processIdentifier,
              let screenFrame = NSScreen.screens.first?.frame,
              let windowInfoList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: AnyObject]]
        else { return false }

        for info in windowInfoList {
            guard let ownerPID = info[kCGWindowOwnerPID as String] as? pid_t, ownerPID == frontPID,
                  let layer = info[kCGWindowLayer as String] as? Int, layer == 0,
                  let boundsDict = info[kCGWindowBounds as String] as? [String: CGFloat]
            else { continue }

            let bounds = CGRect(
                x: boundsDict["X"] ?? 0, y: boundsDict["Y"] ?? 0,
                width: boundsDict["Width"] ?? 0, height: boundsDict["Height"] ?? 0
            )
            // Global-display coordinates (CGWindowListCopyWindowInfo) are top-left
            // origin; NSScreen frames are bottom-left origin — only width/height
            // need to match for this check, so the flip doesn't matter here.
            if abs(bounds.width - screenFrame.width) < 2, abs(bounds.height - screenFrame.height) < 2 {
                return true
            }
        }
        return false
    }
}
