import XCTest

/// Runs Xcode's accessibility audit (contrast, hit targets, clipped text,
/// missing labels, Dynamic Type) on every screen, at the default text size and
/// at the largest accessibility size.
///
/// The audit reads pixels, so it also judges content nobody can see: a row
/// scrolled beneath the floating tab bar, a carousel card peeking past the
/// screen edge, or system chrome the app doesn't draw. Issues count only for
/// elements that are fully visible and belong to the app.
nonisolated final class AccessibilityAuditTests: XCTestCase {
    @MainActor
    func testEveryScreenAtDefaultTextSize() throws {
        try auditEveryScreen(textSize: nil)
    }

    @MainActor
    func testEveryScreenAtLargestTextSize() throws {
        try auditEveryScreen(textSize: "UICTContentSizeCategoryAccessibilityXXXL")
    }
}

// MARK: - Screens
private extension AccessibilityAuditTests {
    @MainActor
    func auditEveryScreen(textSize: String?) throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestMode"]
        if let textSize {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", textSize]
        }
        app.launch()

        let movie = app.staticTexts["The Silent Voyage"].firstMatch
        XCTAssertTrue(movie.waitForExistence(timeout: 25))
        try audit(app)

        movie.tap()
        XCTAssertTrue(app.descendants(matching: .any)["movieDetail.container"].waitForExistence(timeout: 25))
        try audit(app)

        let play = app.buttons["Play Trailer"]
        XCTAssertTrue(play.waitForExistence(timeout: 15))
        play.tap()
        let close = app.buttons["Close"]
        XCTAssertTrue(close.waitForExistence(timeout: 10))
        try audit(app)
        close.tap()
        app.navigationBars.buttons.firstMatch.tap()

        app.tabBars.buttons["Favorites"].tap()
        XCTAssertTrue(app.staticTexts["No Favorites Yet"].waitForExistence(timeout: 15))
        try audit(app)

        app.tabBars.buttons["Search"].tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 15))
        try audit(app)

        field.tap()
        field.typeText("voyage\n")
        XCTAssertTrue(app.staticTexts["The Silent Voyage"].waitForExistence(timeout: 10))
        try audit(app)
    }
}

// MARK: - Audit
private extension AccessibilityAuditTests {
    @MainActor
    func audit(_ app: XCUIApplication) throws {
        let screen = app.windows.firstMatch.frame
        let systemChrome = [app.tabBars, app.searchFields, app.keyboards]
            .flatMap(\.allElementsBoundByIndex)
            .map(\.frame)
        let cutOffCards = app.buttons.allElementsBoundByIndex
            .map(\.frame)
            .filter { screen.intersects($0) && !screen.contains($0) }

        try app.performAccessibilityAudit { issue in
            guard let frame = issue.element?.frame else { return false }
            let isFullyVisible = screen.contains(frame)
                && !cutOffCards.contains { $0.intersects(frame) }
                && !systemChrome.contains { $0.intersects(frame) }
            return !isFullyVisible
        }
    }
}
