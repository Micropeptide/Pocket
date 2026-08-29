import AppKit

/// Owns the two NSStatusItems that make Pocket work: a toggle (created first) and a
/// spacer (created second, sitting just left of the toggle).
///
/// The classic technique other menu-bar managers use (Hidden Bar, Vanilla, Dozer) is
/// to grow the spacer's `length` to push everything to its left off the visible menu
/// bar via macOS's own overflow-clipping. On this machine's macOS version that no
/// longer works reliably: verified empirically (via CGWindowList and live AX
/// queries, not assumption) that every menu-bar item is now hosted out-of-process by
/// Control Center, which runs its own opaque overflow/priority system — resizing the
/// spacer only occasionally flips a marginal item's visibility, not a clean
/// reveal/hide of everything to its left.
///
/// Because of that, the spacer/toggle pair still runs (harmless, and may work
/// cleanly on less-crowded bars or older macOS versions), but it is NOT how Pocket
/// delivers on "show hidden icons" here — clicking the toggle opens
/// HiddenIconsPanelController instead, which lists every app's menu-bar item via AX
/// and opens one with AXUIElementPerformAction(kAXPressAction). That works
/// regardless of whether Control Center currently renders the icon on screen.
@MainActor
final class StatusItemController {

    /// Wide enough to push everything to the spacer's left off the visible menu bar.
    /// Deliberately a fixed constant, not derived from NSScreen: on this machine the
    /// attached-display set changes at runtime (observed dropping from 3 screens to
    /// 1 mid-session), and a screen-width-derived value produced a length so large it
    /// broke layout for Pocket's own toggle item too, not just the hidden icons.
    private static let collapsedSpacerLength: CGFloat = 1000
    private static let expandedSpacerLength: CGFloat = 1

    private(set) var isExpanded = false

    private let toggleItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let spacerItem = NSStatusBar.system.statusItem(withLength: StatusItemController.expandedSpacerLength)

    private lazy var spacerAnimator = SpacerAnimator(statusItem: spacerItem)

    var onOpenSettings: (() -> Void)?
    var onOpenInventory: (() -> Void)?
    var onQuit: (() -> Void)?

    /// Fires whenever expanded/collapsed state changes, for AutoHideController etc.
    var onStateChanged: ((Bool) -> Void)?

    init() {
        configureToggleButton()
        configureSpacerButton()
        // Start collapsed: the spacer item is created at the expanded (1pt) length
        // above, so without this the physical menu bar would show hidden-zone icons
        // until the first click even though `isExpanded` already reads false.
        collapse(animated: false)
    }

    // MARK: Configuration

    private func configureToggleButton() {
        guard let button = toggleItem.button else { return }
        button.target = self
        button.action = #selector(toggleClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.toolTip = "Pocket — click to show hidden menu bar icons"
    }

    private func configureSpacerButton() {
        guard let button = spacerItem.button else { return }
        button.image = nil
        button.title = ""
        // No target/action: purely a geometry placeholder so clicks and Cmd-drags
        // pass through to whatever the user is rearranging across it.
    }

    // MARK: Actions

    @objc private func toggleClicked(_ sender: Any?) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showMenu()
        } else {
            // Opening the panel is the reliable way to reach hidden icons on this
            // macOS version (see file header) — it's the primary click action.
            // The spacer still animates alongside it, best-effort, since it costs
            // nothing and may fully work on less-crowded bars/other macOS versions.
            toggle()
            onOpenInventory?()
        }
    }

    func toggle() {
        isExpanded ? collapse() : expand()
    }

    func expand(animated: Bool = true) {
        isExpanded = true
        if animated {
            spacerAnimator.animate(to: Self.expandedSpacerLength)
        } else {
            spacerAnimator.invalidate()
            spacerItem.length = Self.expandedSpacerLength
        }
        applyIcon()
        onStateChanged?(true)
    }

    func collapse(animated: Bool = true) {
        isExpanded = false
        if animated {
            spacerAnimator.animate(to: Self.collapsedSpacerLength)
        } else {
            spacerAnimator.invalidate()
            spacerItem.length = Self.collapsedSpacerLength
        }
        applyIcon()
        onStateChanged?(false)
    }

    /// Screen X of the spacer's left edge in global display coordinates — used by
    /// MenuBarInventory to classify other apps' icons as hidden vs. always-visible.
    var spacerMinX: CGFloat? {
        spacerItem.button?.window?.frame.minX
    }

    // MARK: Icon

    private func applyIcon() {
        guard let button = toggleItem.button else { return }
        let symbolName = isExpanded ? "chevron.right" : "chevron.left"
        let description = isExpanded ? "Hide menu bar icons" : "Show hidden menu bar icons"
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: description)
        image?.isTemplate = true
        button.image = image
    }

    // MARK: Menu

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: "Show Menu Bar Icons…", action: #selector(menuOpenInventory), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Settings…", action: #selector(menuOpenSettings), keyEquivalent: ",").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Pocket", action: #selector(menuQuit), keyEquivalent: "q").target = self

        toggleItem.menu = menu
        toggleItem.button?.performClick(nil)
        toggleItem.menu = nil
    }

    @objc private func menuOpenInventory() { onOpenInventory?() }
    @objc private func menuOpenSettings() { onOpenSettings?() }
    @objc private func menuQuit() { onQuit?() }
}
