import XCTest

@MainActor
final class ComponentGalleryUITests: XCTestCase {
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
}
