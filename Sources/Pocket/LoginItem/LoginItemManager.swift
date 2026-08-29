import Foundation
import ServiceManagement

/// Registers/unregisters Pocket as a login item via SMAppService (the modern
/// replacement for SMLoginItemSetEnabled). Launching at login is what lets Pocket
/// claim the protected slot next to Control Center before the user manually opens
/// other menu-bar apps — see StatusItemController's header comment for why that
/// matters.
enum LoginItemManager {

    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status == .enabled { return }
                try SMAppService.mainApp.register()
            } else {
                if SMAppService.mainApp.status == .notRegistered { return }
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Pocket: failed to \(enabled ? "register" : "unregister") login item: \(error)")
        }
    }

    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }
}
