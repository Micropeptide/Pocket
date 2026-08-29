import Combine
import Foundation

/// Shared, observable mirror of Defaults for the SwiftUI Settings views. AppKit
/// code (StatusItemController, AutoHideController, HotkeyManager) reads/writes
/// Defaults directly — this exists only so SwiftUI can bind to and re-render on
/// preference changes made from the Settings window.
@MainActor
final class AppState: ObservableObject {

    static let shared = AppState()

    @Published var autoHideOnOutsideClick: Bool {
        didSet { Defaults.autoHideOnOutsideClick = autoHideOnOutsideClick }
    }
    @Published var autoHideIdleSeconds: Double {
        didSet { Defaults.autoHideIdleSeconds = autoHideIdleSeconds }
    }
    @Published var autoHideOnFullscreen: Bool {
        didSet { Defaults.autoHideOnFullscreen = autoHideOnFullscreen }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            guard launchAtLogin != oldValue else { return }
            LoginItemManager.setEnabled(launchAtLogin)
            Defaults.launchAtLoginCache = LoginItemManager.isEnabled
        }
    }
    @Published var iconStyle: IconStyle {
        didSet { Defaults.iconStyle = iconStyle }
    }
    @Published var hotkeyKeyCode: UInt32 {
        didSet {
            Defaults.hotkeyKeyCode = hotkeyKeyCode
            HotkeyManager.shared.register(keyCode: hotkeyKeyCode, modifiers: hotkeyModifiers)
        }
    }
    @Published var hotkeyModifiers: UInt32 {
        didSet {
            Defaults.hotkeyModifiers = hotkeyModifiers
            HotkeyManager.shared.register(keyCode: hotkeyKeyCode, modifiers: hotkeyModifiers)
        }
    }
    @Published var autoCheckForUpdates: Bool {
        didSet {
            Defaults.autoCheckForUpdates = autoCheckForUpdates
            if autoCheckForUpdates {
                UpdateChecker.shared.startAutomaticChecking()
            } else {
                UpdateChecker.shared.stopAutomaticChecking()
            }
        }
    }

    private init() {
        autoHideOnOutsideClick = Defaults.autoHideOnOutsideClick
        autoHideIdleSeconds = Defaults.autoHideIdleSeconds
        autoHideOnFullscreen = Defaults.autoHideOnFullscreen
        launchAtLogin = LoginItemManager.isEnabled
        iconStyle = Defaults.iconStyle
        hotkeyKeyCode = Defaults.hotkeyKeyCode
        hotkeyModifiers = Defaults.hotkeyModifiers
        autoCheckForUpdates = Defaults.autoCheckForUpdates
    }
}
