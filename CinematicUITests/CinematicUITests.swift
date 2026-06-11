import XCTest

final class CinematicUITests: XCTestCase {
    @MainActor
    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Cinematic"].waitForExistence(timeout: 5))
    }
}
