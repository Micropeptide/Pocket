import Carbon.HIToolbox

/// Renders a Carbon keyCode + modifier mask as the conventional macOS symbol string
/// (e.g. "⌃⌥⌘P"). Covers the letter keys, since that's all HotkeyManager's default
/// and any UInt32-persisted custom combo would realistically use.
enum HotkeyFormatter {

    private static let letterKeyCodes: [UInt32: String] = [
        UInt32(kVK_ANSI_A): "A", UInt32(kVK_ANSI_B): "B", UInt32(kVK_ANSI_C): "C",
        UInt32(kVK_ANSI_D): "D", UInt32(kVK_ANSI_E): "E", UInt32(kVK_ANSI_F): "F",
        UInt32(kVK_ANSI_G): "G", UInt32(kVK_ANSI_H): "H", UInt32(kVK_ANSI_I): "I",
        UInt32(kVK_ANSI_J): "J", UInt32(kVK_ANSI_K): "K", UInt32(kVK_ANSI_L): "L",
        UInt32(kVK_ANSI_M): "M", UInt32(kVK_ANSI_N): "N", UInt32(kVK_ANSI_O): "O",
        UInt32(kVK_ANSI_P): "P", UInt32(kVK_ANSI_Q): "Q", UInt32(kVK_ANSI_R): "R",
        UInt32(kVK_ANSI_S): "S", UInt32(kVK_ANSI_T): "T", UInt32(kVK_ANSI_U): "U",
        UInt32(kVK_ANSI_V): "V", UInt32(kVK_ANSI_W): "W", UInt32(kVK_ANSI_X): "X",
        UInt32(kVK_ANSI_Y): "Y", UInt32(kVK_ANSI_Z): "Z",
    ]

    static func describe(keyCode: UInt32, modifiers: UInt32) -> String {
        var result = ""
        if Int(modifiers) & controlKey != 0 { result += "⌃" }
        if Int(modifiers) & optionKey != 0 { result += "⌥" }
        if Int(modifiers) & shiftKey != 0 { result += "⇧" }
        if Int(modifiers) & cmdKey != 0 { result += "⌘" }
        result += letterKeyCodes[keyCode] ?? "(key \(keyCode))"
        return result
    }
}
