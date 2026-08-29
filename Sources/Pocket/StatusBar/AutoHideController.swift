import AppKit

/// Automatically collapses the hidden-icon zone after the user clicks elsewhere or
/// after an idle timeout — both opt-in via Defaults, both wired to
/// StatusItemController's expand/collapse rather than owning that state themselves.
///
/// `NSEvent.addGlobalMonitorForEvents` only reports events delivered to *other*
/// applications, so it never fires for clicks on Pocket's own toggle/spacer
/// buttons — no risk of it fighting the button's own click handling.
@MainActor
final class AutoHideController {

    private var outsideClickMonitor: Any?
    private var idleTimer: Timer?

    private let collapse: () -> Void

    init(collapse: @escaping () -> Void) {
        self.collapse = collapse
    }

    /// Call whenever StatusItemController's expanded state changes.
    func statusChanged(isExpanded: Bool) {
        if isExpanded {
            startWatching()
        } else {
            stopWatching()
        }
    }

    private func startWatching() {
        if Defaults.autoHideOnOutsideClick, outsideClickMonitor == nil {
            outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                self?.collapse()
            }
        }

        let idleSeconds = Defaults.autoHideIdleSeconds
        if idleSeconds > 0 {
            idleTimer?.invalidate()
            idleTimer = Timer.scheduledTimer(withTimeInterval: idleSeconds, repeats: false) { [weak self] _ in
                Task { @MainActor in self?.collapse() }
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
