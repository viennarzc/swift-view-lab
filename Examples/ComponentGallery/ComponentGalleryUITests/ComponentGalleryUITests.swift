import XCTest

@MainActor
final class ComponentGalleryUITests: XCTestCase {
    func testThermostatPair() {
        let app = XCUIApplication()
        continueAfterFailure = false
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Thermostat dial")).firstMatch.tap()
        let dial = app.descendants(matching: .any)["thermostatDial"].firstMatch
        XCTAssertTrue(dial.waitForExistence(timeout: 5))
        // Form exposes the full row as the accessibility frame. Use offsets from
        // its center to hit the ring, which is capped at 320 points on iPad.
        // Twelve o'clock is halfway through the sweep: 23°C.
        dial.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).withOffset(CGVector(dx: 0, dy: -120)).tap()
        XCTAssertTrue(app.staticTexts["selectedTemperature"].label.contains("23°C"))
        app.segmentedControls.buttons["UIKit"].tap()
        XCTAssertTrue(app.staticTexts["selectedTemperature"].label.contains("23°C"))
        dial.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).withOffset(CGVector(dx: 120, dy: 0)).tap()
        XCTAssertTrue(app.staticTexts["selectedTemperature"].label.contains("27.5°C"))
        // Center touches must not change the value.
        dial.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertTrue(app.staticTexts["selectedTemperature"].label.contains("27.5°C"))
        let enabled = app.switches["Dial enabled"]
        enabled.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        dial.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).withOffset(CGVector(dx: 0, dy: -120)).tap()
        XCTAssertTrue(app.staticTexts["selectedTemperature"].label.contains("27.5°C"))
        app.segmentedControls.buttons["SwiftUI"].tap()
        dial.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).withOffset(CGVector(dx: 0, dy: -120)).tap()
        XCTAssertTrue(app.staticTexts["selectedTemperature"].label.contains("27.5°C"))
    }

    func testPairedButtonsAndSharedState() {
        let app = XCUIApplication()
        continueAfterFailure = false
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Animated button")).firstMatch.tap()

        let button = app.buttons["studyButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
        XCTAssertEqual(app.staticTexts["actionCount"].label, "Actions, 1")

        app.segmentedControls.buttons["UIKit"].tap()
        XCTAssertEqual(app.staticTexts["actionCount"].label, "Actions, 1")
        button.tap()
        XCTAssertEqual(app.staticTexts["actionCount"].label, "Actions, 2")

        let enabled = app.switches["Button enabled"]
        enabled.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(enabled.value as? String, "0")
        XCTAssertFalse(button.isEnabled)
        app.segmentedControls.buttons["SwiftUI"].tap()
        XCTAssertEqual(enabled.value as? String, "0")
        XCTAssertFalse(button.isEnabled)
        XCTAssertEqual(app.staticTexts["actionCount"].label, "Actions, 2")
        enabled.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        button.tap()
        XCTAssertEqual(app.staticTexts["actionCount"].label, "Actions, 3")
    }

    func testMechanicalRockerRenderersPreserveState() {
        let app = XCUIApplication()
        continueAfterFailure = false
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Mechanical rocker")).firstMatch.tap()
        // A ToggleStyle preserves the toggle role in the accessibility tree,
        // even though its visible renderer is backed by a native Button.
        let rocker = app.descendants(matching: .any)["mechanicalRocker"].firstMatch
        XCTAssertTrue(rocker.waitForExistence(timeout: 5))
        rocker.tap()
        XCTAssertEqual(app.staticTexts["rockerActivationCount"].label, "Activations, 1")

        app.segmentedControls.buttons["USDZ 3D"].tap()
        XCTAssertEqual(app.staticTexts["State"].label, "State, On")
        XCTAssertEqual(app.staticTexts["rockerActivationCount"].label, "Activations, 1")
        rocker.tap()
        XCTAssertEqual(app.staticTexts["rockerActivationCount"].label, "Activations, 2")

        app.segmentedControls.buttons["Static images"].tap()
        XCTAssertEqual(app.staticTexts["rockerActivationCount"].label, "Activations, 2")
        let enabled = app.switches["Rocker enabled"]
        enabled.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertFalse(rocker.isEnabled)
        rocker.tap()
        XCTAssertEqual(app.staticTexts["rockerActivationCount"].label, "Activations, 2")
    }
}
