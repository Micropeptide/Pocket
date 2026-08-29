import AppKit

/// Automatically closes the icon list window after the user clicks elsewhere or
/// after an idle timeout — both opt-in via Defaults, both wired to
/// HiddenIconsPanelController's open/close rather than owning that state themselves.
///
/// `NSEvent.addGlobalMonitorForEvents` only reports events delivered to *other*
/// applications, so it never fires for clicks on Pocket's own status item or its
/// own panel window — no risk of it fighting the window's own click handling.
@MainActor
final class AutoHideController {

    private var outsideClickMonitor: Any?
    private var idleTimer: Timer?

    private let close: () -> Void

    init(collapse: @escaping () -> Void) {
        self.close = collapse
    }

    /// Call whenever the panel's open/closed state changes.
    func statusChanged(isExpanded isOpen: Bool) {
        if isOpen {
            startWatching()
        } else {
            stopWatching()
        }
    }

    private func startWatching() {
        if Defaults.autoHideOnOutsideClick, outsideClickMonitor == nil {
            outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                self?.close()
            }
        }

        let idleSeconds = Defaults.autoHideIdleSeconds
        if idleSeconds > 0 {
            idleTimer?.invalidate()
            idleTimer = Timer.scheduledTimer(withTimeInterval: idleSeconds, repeats: false) { [weak self] _ in
                Task { @MainActor in self?.close() }
            }
        }
    }

    private func stopWatching() {
        if let outsideClickMonitor {
            NSEvent.removeMonitor(outsideClickMonitor)
            self.outsideClickMonitor = nil
        }
        idleTimer?.invalidate()
        idleTimer = nil
    }
}
