import XCTest
@testable import Pocket

final class DefaultsTests: XCTestCase {

    override func tearDown() {
        // Reset to defaults so tests stay independent of run order.
        Defaults.autoHideOnOutsideClick = true
        Defaults.autoHideIdleSeconds = 0
        Defaults.autoHideOnFullscreen = true
        Defaults.hotkeyKeyCode = Defaults.defaultHotkeyKeyCode
        Defaults.hotkeyModifiers = Defaults.defaultHotkeyModifiers
        Defaults.onboardingCompleted = false
        Defaults.iconStyle = .chevron
        super.tearDown()
    }

    func testAutoHideOnOutsideClickRoundTrips() {
        Defaults.autoHideOnOutsideClick = false
        XCTAssertFalse(Defaults.autoHideOnOutsideClick)
        Defaults.autoHideOnOutsideClick = true
        XCTAssertTrue(Defaults.autoHideOnOutsideClick)
    }

    func testAutoHideIdleSecondsRoundTrips() {
        Defaults.autoHideIdleSeconds = 12.5
        XCTAssertEqual(Defaults.autoHideIdleSeconds, 12.5)
    }

    func testHotkeyRoundTrips() {
        Defaults.hotkeyKeyCode = 99
        Defaults.hotkeyModifiers = 42
        XCTAssertEqual(Defaults.hotkeyKeyCode, 99)
        XCTAssertEqual(Defaults.hotkeyModifiers, 42)
    }

    func testHotkeyDefaultsWhenUnset() {
        // tearDown already resets to defaults; re-assert the fallback path directly
        // reads the same constants exposed for the Settings UI.
        XCTAssertEqual(Defaults.hotkeyKeyCode, Defaults.defaultHotkeyKeyCode)
        XCTAssertEqual(Defaults.hotkeyModifiers, Defaults.defaultHotkeyModifiers)
    }

    func testIconStyleRoundTrips() {
        Defaults.iconStyle = .pocket
        XCTAssertEqual(Defaults.iconStyle, .pocket)
    }

    func testOnboardingCompletedDefaultsFalse() {
        XCTAssertFalse(Defaults.onboardingCompleted)
        Defaults.onboardingCompleted = true
        XCTAssertTrue(Defaults.onboardingCompleted)
    }
}
