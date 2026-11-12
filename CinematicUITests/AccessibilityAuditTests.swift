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

        app.tapGenre("Drama")
        XCTAssertTrue(movie.waitForNonExistence(timeout: 10))
        try audit(app, isAccessibilitySize: isAccessibilitySize)
        app.tapGenre("All")
        XCTAssertTrue(movie.waitForExistence(timeout: 10))

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
    @MainActor
    func descendants(of snapshot: any XCUIElementSnapshot) -> [any XCUIElementSnapshot] {
        snapshot.children.flatMap { [$0] + descendants(of: $0) }
    }

    /// A tab's button, whether it sits in the iPhone tab bar or in iPad's
    /// sidebar-adaptable bar, which isn't a tab bar element.
    @MainActor
    func tab(_ title: String, in app: XCUIApplication) -> XCUIElement {
        let tabBarButton = app.tabBars.buttons[title]
        return tabBarButton.exists ? tabBarButton : app.buttons[title].firstMatch
    }

    /// Frames the audit's issues are judged against.
    struct Layout {
        let screen: CGRect
        let systemChrome: [CGRect]
        let cutOffCards: [CGRect]
        let cards: [CGRect]
    }

    /// One snapshot of the whole tree; querying elements one by one costs a
    /// round trip each, which is slow enough on CI to starve the audit.
    @MainActor
    func layout(of app: XCUIApplication) throws -> Layout {
        let root = try app.snapshot()
        let screen = root.frame
        let elements = descendants(of: root)
        let buttons = elements.filter { $0.elementType == .button }
        return Layout(
            screen: screen,
            systemChrome: elements
                .filter { [.tabBar, .searchField, .keyboard].contains($0.elementType) }
                .map(\.frame),
            cutOffCards: buttons
                .map(\.frame)
                .filter { screen.intersects($0) && !screen.contains($0) },
            // Inset outward by a point: a caption on a card's bottom edge can sit
            // a fraction past the card's frame and would otherwise escape the match.
            cards: buttons
                .filter { $0.identifier == "movie.card" }
                .map { $0.frame.insetBy(dx: -1, dy: -1) },
        )
    }

    @MainActor
    func audit(_ app: XCUIApplication, isAccessibilitySize: Bool) throws {
        // Read lazily, at the first issue: by then the layout the last action
        // set off (a navigation bar growing a subtitle, say) has settled, so
        // the frames match the ones the audit reports.
        var layout: Layout?

        try app.performAccessibilityAudit { issue in
            guard let element = issue.element else { return false }
            let frame = element.frame
            if layout == nil {
                layout = try? self.layout(of: app)
            }
            guard let layout else {
                XCTFail("Couldn't snapshot the screen to judge: \(issue.compactDescription)")
                return true
            }
            let isFullyVisible = layout.screen.contains(frame)
                && !layout.cutOffCards.contains { $0.intersects(frame) }
                && !layout.systemChrome.contains { $0.intersects(frame) }
            guard isFullyVisible else { return true }
            let isTruncation = issue.auditType == .textClipped || issue.auditType == .dynamicType
            if !isAccessibilitySize, isTruncation, layout.cards.contains(where: { $0.contains(frame) }) {
                return true
            }
            // Reported here rather than by the audit, whose message doesn't name the element.
            XCTFail("\(issue.compactDescription): \(element.elementType) '\(element.label)' at \(frame)")
            return true
        }
    }
}
