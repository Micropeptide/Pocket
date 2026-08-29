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
        let autoHide = AutoHideController(collapse: { [weak panel] in
            panel?.close()
        })

        panel.onVisibilityChanged = { [weak autoHide] isOpen in
            autoHide?.statusChanged(isExpanded: isOpen)
        }
        panel.onOpenSettings = { [weak settings] in
            settings?.show()
        }

        controller.onQuit = {
            NSApp.terminate(nil)
        }
        controller.onOpenSettings = { [weak settings] in
            settings?.show()
        }
        controller.onOpenInventory = { [weak panel] in
            panel?.toggle()
        }

        let fullscreen = FullscreenObserver()
        fullscreen.onChange = { [weak panel] isFullscreen in
            guard isFullscreen, Defaults.autoHideOnFullscreen, panel?.isOpen == true else { return }
            panel?.close()
        }

        HotkeyManager.shared.onPressed = { [weak panel] in
            panel?.toggle()
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
