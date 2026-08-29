import Foundation

/// Pure geometry: classifies an icon's zone by comparing its screen X position
/// against the spacer's left edge. Kept free of any AX/AppKit I/O so it's
/// unit-testable without a live accessibility tree (see ZoneClassifierTests).
///
/// Icons to the spacer's left are pushed off-screen when Pocket is collapsed —
/// that's the hidden zone. Icons at or to the right of the spacer are always
/// visible.
enum ZoneClassifier {
    static func classify(iconX: CGFloat, spacerMinX: CGFloat) -> MenuBarZone {
        iconX < spacerMinX ? .hidden : .alwaysVisible
    }
}
