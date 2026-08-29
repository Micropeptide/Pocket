import Foundation
import Carbon.HIToolbox

/// Thin, typed wrapper around UserDefaults. Single source of truth for every
/// persisted preference so key names and default values live in one place.
enum Defaults {

    private static let store = UserDefaults.standard

    private enum Key: String {
        case autoHideOnOutsideClick
        case autoHideIdleSeconds
        case autoHideOnFullscreen
        case hotkeyKeyCode
        case hotkeyModifiers
        case onboardingCompleted
        case launchAtLoginCache
        case iconStyle
        case autoCheckForUpdates
        case lastUpdateCheckDate
    }

    // MARK: Auto-hide behaviors

    static var autoHideOnOutsideClick: Bool {
        get { store.object(forKey: Key.autoHideOnOutsideClick.rawValue) as? Bool ?? true }
        set { store.set(newValue, forKey: Key.autoHideOnOutsideClick.rawValue) }
    }

    /// 0 disables the idle auto-hide timer entirely.
    static var autoHideIdleSeconds: Double {
        get { store.object(forKey: Key.autoHideIdleSeconds.rawValue) as? Double ?? 0 }
        set { store.set(newValue, forKey: Key.autoHideIdleSeconds.rawValue) }
    }

    static var autoHideOnFullscreen: Bool {
        get { store.object(forKey: Key.autoHideOnFullscreen.rawValue) as? Bool ?? true }
        set { store.set(newValue, forKey: Key.autoHideOnFullscreen.rawValue) }
    }

    // MARK: Hotkey

    /// kVK_ANSI_P — chosen to avoid colliding with Firefly's default ⌃⌥⌘W on the
    /// same machine.
    static let defaultHotkeyKeyCode: UInt32 = 35
    static let defaultHotkeyModifiers: UInt32 = UInt32(controlKey | optionKey | cmdKey)

    static var hotkeyKeyCode: UInt32 {
        get { UInt32(store.object(forKey: Key.hotkeyKeyCode.rawValue) as? Int ?? Int(Self.defaultHotkeyKeyCode)) }
        set { store.set(Int(newValue), forKey: Key.hotkeyKeyCode.rawValue) }
    }

    static var hotkeyModifiers: UInt32 {
        get { UInt32(store.object(forKey: Key.hotkeyModifiers.rawValue) as? Int ?? Int(Self.defaultHotkeyModifiers)) }
        set { store.set(Int(newValue), forKey: Key.hotkeyModifiers.rawValue) }
    }

    // MARK: Onboarding / misc

    static var onboardingCompleted: Bool {
        get { store.bool(forKey: Key.onboardingCompleted.rawValue) }
        set { store.set(newValue, forKey: Key.onboardingCompleted.rawValue) }
    }

    /// Cached mirror of SMAppService's real status, so Settings can render instantly
    /// without a synchronous system call; StatusItemController/Settings reconcile this
    /// against LoginItemManager.isEnabled on demand.
    static var launchAtLoginCache: Bool {
        get { store.bool(forKey: Key.launchAtLoginCache.rawValue) }
        set { store.set(newValue, forKey: Key.launchAtLoginCache.rawValue) }
    }

    static var iconStyle: IconStyle {
        get { IconStyle(rawValue: store.string(forKey: Key.iconStyle.rawValue) ?? "") ?? .chevron }
        set { store.set(newValue.rawValue, forKey: Key.iconStyle.rawValue) }
    }

    // MARK: Updates

    /// Opt-in, user-controlled. Only ever checks GitHub Releases and notifies —
    /// never downloads or installs anything automatically.
    static var autoCheckForUpdates: Bool {
        get { store.object(forKey: Key.autoCheckForUpdates.rawValue) as? Bool ?? true }
        set { store.set(newValue, forKey: Key.autoCheckForUpdates.rawValue) }
    }

    static var lastUpdateCheckDate: Date? {
        get { store.object(forKey: Key.lastUpdateCheckDate.rawValue) as? Date }
        set { store.set(newValue, forKey: Key.lastUpdateCheckDate.rawValue) }
    }
}

enum IconStyle: String, CaseIterable, Identifiable, Equatable {
    case chevron
    case pocket
    case dots

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chevron: return "Chevron"
        case .pocket: return "Pocket"
        case .dots: return "Dots"
        }
    }
}
