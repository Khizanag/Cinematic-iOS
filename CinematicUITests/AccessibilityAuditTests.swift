import XCTest

/// Runs Xcode's accessibility audit (contrast, hit targets, clipped text,
/// missing labels, Dynamic Type) on every screen, at the default text size and
/// at the largest accessibility size.
///
/// The audit reads pixels, so it also judges content nobody can see: a row
/// scrolled beneath the floating tab bar, a carousel card peeking past the
/// screen edge, or system chrome the app doesn't draw. Issues count only for
/// elements that are fully visible and belong to the app.
///
/// Movie cards truncate long titles by design at regular text sizes: a card is
/// a compact preview, VoiceOver reads its full title, and the detail screen
/// shows it. So truncation inside a card is allowed at the default size and
/// must not happen at the largest size, where cards give their text room.
nonisolated final class AccessibilityAuditTests: XCTestCase {
    @MainActor
    func testEveryScreenAtDefaultTextSize() throws {
        try auditEveryScreen(textSize: nil, isAccessibilitySize: false)
    }

    @MainActor
    func testEveryScreenAtLargestTextSize() throws {
        try auditEveryScreen(textSize: "UICTContentSizeCategoryAccessibilityXXXL", isAccessibilitySize: true)
    }
}

// MARK: - Screens
private extension AccessibilityAuditTests {
    @MainActor
    func auditEveryScreen(textSize: String?, isAccessibilitySize: Bool) throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestMode"]
        if let textSize {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", textSize]
        }
        app.launch()

        let movie = app.staticTexts["The Silent Voyage"].firstMatch
        XCTAssertTrue(movie.waitForExistence(timeout: 25))
        try audit(app, isAccessibilitySize: isAccessibilitySize)

        movie.tap()
        XCTAssertTrue(app.descendants(matching: .any)["movieDetail.container"].waitForExistence(timeout: 25))
        try audit(app, isAccessibilitySize: isAccessibilitySize)

        let play = app.buttons["Play Trailer"]
        XCTAssertTrue(play.waitForExistence(timeout: 15))
        play.tap()
        let close = app.buttons["Close"]
        XCTAssertTrue(close.waitForExistence(timeout: 10))
        try audit(app, isAccessibilitySize: isAccessibilitySize)
        close.tap()
        app.navigationBars.buttons.firstMatch.tap()

        tab("Favorites", in: app).tap()
        XCTAssertTrue(app.staticTexts["No Favorites Yet"].waitForExistence(timeout: 15))
        try audit(app, isAccessibilitySize: isAccessibilitySize)

        tab("Search", in: app).tap()
        let field = app.searchFields.firstMatch
        if !field.waitForExistence(timeout: 5) {
            // iPad collapses the search field into a toolbar button.
            app.navigationBars.buttons["Search"].firstMatch.tap()
        }
        XCTAssertTrue(field.waitForExistence(timeout: 15))
        try audit(app, isAccessibilitySize: isAccessibilitySize)

        field.tap()
        field.typeText("voyage\n")
        XCTAssertTrue(app.staticTexts["The Silent Voyage"].waitForExistence(timeout: 10))
        try audit(app, isAccessibilitySize: isAccessibilitySize)
    }
}

// MARK: - Audit
private extension AccessibilityAuditTests {
    /// A tab's button, whether it sits in the iPhone tab bar or in iPad's
    /// sidebar-adaptable bar, which isn't a tab bar element.
    @MainActor
    func tab(_ title: String, in app: XCUIApplication) -> XCUIElement {
        let tabBarButton = app.tabBars.buttons[title]
        return tabBarButton.exists ? tabBarButton : app.buttons[title].firstMatch
    }

    @MainActor
    func audit(_ app: XCUIApplication, isAccessibilitySize: Bool) throws {
        let screen = app.windows.firstMatch.frame
        let systemChrome = [app.tabBars, app.searchFields, app.keyboards]
            .flatMap(\.allElementsBoundByIndex)
            .map(\.frame)
        let cutOffCards = app.buttons.allElementsBoundByIndex
            .map(\.frame)
            .filter { screen.intersects($0) && !screen.contains($0) }
        let cards = app.buttons.matching(identifier: "movie.card").allElementsBoundByIndex.map(\.frame)

        try app.performAccessibilityAudit { issue in
            guard let element = issue.element else { return false }
            let frame = element.frame
            let isFullyVisible = screen.contains(frame)
                && !cutOffCards.contains { $0.intersects(frame) }
                && !systemChrome.contains { $0.intersects(frame) }
            guard isFullyVisible else { return true }
            let isTruncation = issue.auditType == .textClipped || issue.auditType == .dynamicType
            if !isAccessibilitySize, isTruncation, cards.contains(where: { $0.contains(frame) }) {
                return true
            }
            // Reported here rather than by the audit, whose message doesn't name the element.
            XCTFail("\(issue.compactDescription): \(element.elementType) '\(element.label)' at \(frame)")
            return true
        }
    }
}
