import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItemController: StatusItemController?
    private var autoHideController: AutoHideController?
    private var fullscreenObserver: FullscreenObserver?
    private var hiddenIconsPanel: HiddenIconsPanelController?
    private var settingsWindow: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = StatusItemController()
        let panel = HiddenIconsPanelController()
        let settings = SettingsWindowController()
        let autoHide = AutoHideController(collapse: { [weak controller, weak panel] in
            controller?.collapse()
            panel?.close()
        })

        controller.onStateChanged = { [weak autoHide] isExpanded in
            autoHide?.statusChanged(isExpanded: isExpanded)
        }
        controller.onQuit = {
            NSApp.terminate(nil)
        }
        controller.onOpenSettings = { [weak settings] in
            settings?.show()
        }
        controller.onOpenInventory = { [weak panel] in
            panel?.show()
        }
        panel.onOpenSettings = { [weak settings] in
            settings?.show()
        }

        let fullscreen = FullscreenObserver()
        fullscreen.onChange = { [weak controller] isFullscreen in
            guard isFullscreen, Defaults.autoHideOnFullscreen, controller?.isExpanded == true else { return }
            controller?.collapse()
        }

        HotkeyManager.shared.onPressed = { [weak controller, weak panel] in
            controller?.toggle()
            panel?.show()
        }
        HotkeyManager.shared.registerFromDefaults()

        NotificationHelper.requestAuthorization()
        if Defaults.autoCheckForUpdates {
            UpdateChecker.shared.startAutomaticChecking()
        }

        statusItemController = controller
        autoHideController = autoHide
        fullscreenObserver = fullscreen
        hiddenIconsPanel = panel
        settingsWindow = settings
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotkeyManager.shared.unregister()
        UpdateChecker.shared.stopAutomaticChecking()
        statusItemController = nil
        autoHideController = nil
        fullscreenObserver = nil
        hiddenIconsPanel = nil
        settingsWindow = nil
    }
}
