import AppKit

/// Animates an `NSStatusItem`'s `length` between two values with an ease-out curve.
/// `length` is a plain CGFloat property — not KVO/layer-animatable — so there is no
/// built-in shortcut here; a repeating Timer drives the interpolation.
@MainActor
final class SpacerAnimator {

    private weak var statusItem: NSStatusItem?
    private var timer: Timer?
    private var startLength: CGFloat = 0
    private var targetLength: CGFloat = 0
    private var startTime: CFAbsoluteTime = 0
    private let duration: CFAbsoluteTime

    init(statusItem: NSStatusItem, duration: CFAbsoluteTime = 0.22) {
        self.statusItem = statusItem
        self.duration = duration
    }

    func animate(to targetLength: CGFloat, completion: (() -> Void)? = nil) {
        guard let statusItem else { return }
        timer?.invalidate()

        startLength = statusItem.length
        self.targetLength = targetLength
        startTime = CFAbsoluteTimeGetCurrent()

        guard startLength != targetLength else {
            statusItem.length = targetLength
            completion?()
            return
        }

        let newTimer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] timer in
            MainActor.assumeIsolated {
                guard let self, let statusItem = self.statusItem else {
                    timer.invalidate()
                    return
                }
                let elapsed = CFAbsoluteTimeGetCurrent() - self.startTime
                let t = min(1, elapsed / self.duration)
                let eased = 1 - pow(1 - t, 3) // ease-out cubic
                statusItem.length = self.startLength + (self.targetLength - self.startLength) * CGFloat(eased)

                if t >= 1 {
                    timer.invalidate()
                    self.timer = nil
                    completion?()
                }
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}
