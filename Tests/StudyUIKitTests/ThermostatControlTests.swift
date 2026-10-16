import XCTest
import UIKit
@testable import StudyUIKit

@MainActor final class ThermostatControlTests: XCTestCase {
    func testEventsAccessibilityAndDisabledState() {
        let dial = StudyThermostatDial()
        let receiver = Receiver()
        dial.addAction(UIAction { _ in receiver.changed() }, for: .valueChanged)
        dial.temperature = 29.5
        XCTAssertEqual(receiver.count, 0)
        dial.accessibilityIncrement()
        XCTAssertEqual(dial.temperature, 30)
        XCTAssertEqual(receiver.count, 1)
        dial.accessibilityIncrement()
        XCTAssertEqual(receiver.count, 1)
        dial.isEnabled = false
        dial.accessibilityDecrement()
        XCTAssertEqual(dial.temperature, 30)
        XCTAssertEqual(receiver.count, 1)
        dial.isEnabled = true
        dial.accessibilityDecrement()
        XCTAssertEqual(dial.temperature, 29.5)
        XCTAssertEqual(receiver.count, 2)
    }
    @MainActor private final class Receiver: NSObject {
        var count = 0
        @objc func changed() { count += 1 }
    }
}
