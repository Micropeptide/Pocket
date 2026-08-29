import Carbon.HIToolbox
import AppKit

/// Registers a single systemwide keyboard shortcut that toggles Pocket's hidden
/// icons from any app. Uses the classic Carbon hot-key API — registering one
/// specific combo this way does not require Accessibility/Input Monitoring
/// permission, unlike a global keystroke tap.
@MainActor
final class HotkeyManager {

    static let shared = HotkeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x504F434B), id: 1) // 'POCK'

    /// Fires on the main actor when the registered combo is pressed.
    var onPressed: (() -> Void)?

    private init() {}

    func registerFromDefaults() {
        register(keyCode: Defaults.hotkeyKeyCode, modifiers: Defaults.hotkeyModifiers)
    }

    func register(keyCode: UInt32, modifiers: UInt32) {
        unregister()

        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in
            Task { @MainActor in HotkeyManager.shared.onPressed?() }
            return noErr
        }, 1, &eventSpec, nil, &eventHandlerRef)

        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        if status != noErr {
            hotKeyRef = nil
            NSLog("Pocket: failed to register global hot key (status \(status))")
        }
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }

    /// True if `register` most recently succeeded — used by the Settings UI to
    /// surface a conflict warning when another app already owns the combo.
    var isRegistered: Bool { hotKeyRef != nil }
}
