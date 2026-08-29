import ApplicationServices

/// Thin wrapper around the Accessibility trust check. Gates MenuBarInventory —
/// core hide/show never requires this, only the optional Inventory panel does.
///
/// Note for local development: ad-hoc code signing (`codesign --sign -`, used by
/// Scripts/build-app.sh since there's no paid Developer ID in this environment)
/// regenerates the app's code identity on every rebuild, and this grant is tied to
/// that identity. Expect to re-grant Accessibility after each rebuild during
/// development — confirmed via testing, not hypothetical. If a re-grant via System
/// Settings' toggle doesn't seem to take effect, `tccutil reset Accessibility
/// com.micropeptide.pocket` followed by a fresh grant through the in-app prompt
/// (not just toggling the Settings list) reliably clears it. A real Developer ID
/// signature (needed for distribution anyway) will make this a non-issue.
enum AccessibilityPermission {

    static var isGranted: Bool {
        AXIsProcessTrusted()
    }

    /// Prompts the system permission dialog if not already granted. Returns the
    /// trust state at call time (the user must grant it and Pocket must be
    /// re-queried afterward — there's no synchronous "wait for grant" API).
    @discardableResult
    static func requestIfNeeded() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
}
