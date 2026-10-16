import XCTest
@testable import StudyUIKit

final class ThermostatGeometryTests: XCTestCase {
    func testScaleAndSnapping() {
        let scale = ThermostatScale(range: 16...30, step: 0.5)
        XCTAssertEqual(scale.value(at: 0), 16)
        XCTAssertEqual(scale.value(at: 135), 23)
        XCTAssertEqual(scale.value(at: 270), 30)
        XCTAssertEqual(scale.value(at: -20), 16)
        XCTAssertEqual(scale.value(at: 300), 30)
        XCTAssertEqual(scale.snapped(22.26), 22.5)
        XCTAssertEqual(scale.snapped(.nan), 16)
        XCTAssertEqual(ThermostatScale(range: -10...10, step: 2).snapped(-7), -6)
    }

    func testScreenAngles() {
        let center = CGPoint(x: 100, y: 100)
        XCTAssertEqual(ThermostatScale.angle(at: CGPoint(x: 100, y: 0), center: center), 135, accuracy: 0.001)
        XCTAssertEqual(ThermostatScale.angle(at: CGPoint(x: 200, y: 100), center: center), 225, accuracy: 0.001)
    }

    func testGapDoesNotWrapAndReverseReturnsToArc() {
        var drag = ThermostatDrag()
        let scale = ThermostatScale(range: 16...30, step: 0.5)
        XCTAssertFalse(drag.begin(300))
        XCTAssertTrue(drag.begin(260))
        for angle in [280.0, 320, 359, 1, 15] { drag.move(angle); XCTAssertEqual(scale.value(at: drag.angle!), 30) }
        for angle in [1.0, 359, 320, 280, 260] { drag.move(angle) }
        XCTAssertEqual(drag.angle!, 260, accuracy: 0.001)
        XCTAssertTrue(drag.begin(10))
        for angle in [1.0, 359, 320, 280] { drag.move(angle); XCTAssertEqual(scale.value(at: drag.angle!), 16) }
    }
}
