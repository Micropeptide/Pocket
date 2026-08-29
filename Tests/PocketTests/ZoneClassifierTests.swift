import XCTest
@testable import Pocket

final class ZoneClassifierTests: XCTestCase {

    func testIconLeftOfSpacerIsHidden() {
        XCTAssertEqual(ZoneClassifier.classify(iconX: 100, spacerMinX: 200), .hidden)
    }

    func testIconRightOfSpacerIsAlwaysVisible() {
        XCTAssertEqual(ZoneClassifier.classify(iconX: 300, spacerMinX: 200), .alwaysVisible)
    }

    func testIconExactlyAtSpacerEdgeIsAlwaysVisible() {
        XCTAssertEqual(ZoneClassifier.classify(iconX: 200, spacerMinX: 200), .alwaysVisible)
    }
}
