import XCTest

/// Smoke flows over the stubbed app (`-uiTestMode` injects the in-memory
/// preview world, so these are deterministic and run offline).
///
/// The class is `nonisolated` because the target builds with default
/// MainActor isolation, which conflicts with XCTestCase's nonisolated
/// overrides; each test hops back via `@MainActor`.
nonisolated final class CinematicUITests: XCTestCase {
    @MainActor
    func testDiscoverToDetailToFavoritesFlow() {
        let app = launchStubbedApp()

        XCTAssertTrue(app.staticTexts["The Silent Voyage"].waitForExistence(timeout: 10))
        app.staticTexts["The Silent Voyage"].firstMatch.tap()

        let detail = app.descendants(matching: .any)["movieDetail.container"]
        XCTAssertTrue(detail.waitForExistence(timeout: 5))

        app.buttons["Add to Favorites"].tap()

        app.navigationBars.buttons.firstMatch.tap()
        app.tabBars.buttons["Favorites"].tap()
        XCTAssertTrue(app.staticTexts["The Silent Voyage"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testTrailerCoverOpensAndCloses() {
        let app = launchStubbedApp()

        XCTAssertTrue(app.staticTexts["The Silent Voyage"].waitForExistence(timeout: 10))
        app.staticTexts["The Silent Voyage"].firstMatch.tap()

        let play = app.buttons["Play Trailer"]
        XCTAssertTrue(play.waitForExistence(timeout: 5))
        play.tap()

        let close = app.buttons["Close"]
        XCTAssertTrue(close.waitForExistence(timeout: 5))
        close.tap()

        XCTAssertTrue(play.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSearchFindsCatalogMovie() {
        let app = launchStubbedApp()

        app.tabBars.buttons["Search"].tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("voyage")

        XCTAssertTrue(app.staticTexts["The Silent Voyage"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testFavoritesStartEmpty() {
        let app = launchStubbedApp()

        app.tabBars.buttons["Favorites"].tap()

        XCTAssertTrue(app.staticTexts["No Favorites Yet"].waitForExistence(timeout: 5))
    }
}

// MARK: - Helpers
private extension CinematicUITests {
    @MainActor
    func launchStubbedApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestMode"]
        app.launch()
        return app
    }
}
