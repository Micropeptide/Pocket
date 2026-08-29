import Combine
import Foundation

@MainActor
final class HiddenIconsPanelModel: ObservableObject {
    @Published var icons: [MenuBarIconInfo] = []
    @Published var isAccessibilityGranted: Bool = AccessibilityPermission.isGranted

    var onOpenSettings: (() -> Void)?

    func refresh() {
        isAccessibilityGranted = AccessibilityPermission.isGranted
        guard isAccessibilityGranted else {
            icons = []
            return
        }
        icons = MenuBarInventory.fetch().icons
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
