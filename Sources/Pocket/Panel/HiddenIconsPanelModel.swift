import Combine
import Foundation

@MainActor
final class HiddenIconsPanelModel: ObservableObject {
    @Published var icons: [MenuBarIconInfo] = []
    @Published var isAccessibilityGranted: Bool = AccessibilityPermission.isGranted
    @Published var isLoading = false

    var onOpenSettings: (() -> Void)?

    /// Bumped on every refresh so a slow background scan can't clobber a newer one
    /// with stale results if the panel is closed/reopened quickly.
    private var refreshGeneration = 0

    func refresh() {
        isAccessibilityGranted = AccessibilityPermission.isGranted
        guard isAccessibilityGranted else {
            icons = []
            isLoading = false
            return
        }

        refreshGeneration += 1
        let generation = refreshGeneration
        isLoading = true

        // MenuBarInventory.fetch() makes a synchronous cross-process AX call per
        // running app — with dozens of apps that's real wall-clock time, so it
        // runs off the main thread to keep the window responsive when it opens.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = MenuBarInventory.fetch()
            DispatchQueue.main.async {
                guard let self, generation == self.refreshGeneration else { return }
                self.icons = result
                self.isLoading = false
            }
        }
    }

    func requestAccessibility() {
        AccessibilityPermission.requestIfNeeded()
        // The system permission dialog is asynchronous and app-wide; poll briefly
        // so the panel updates itself once the user grants it without requiring a
        // manual refresh click.
        for delay in [1.0, 2.0, 4.0] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.refresh()
            }
        }
    }
}
