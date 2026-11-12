import XCTest

// MARK: - Genre filter
extension XCUIApplication {
    /// Discover's genre menu in the navigation bar.
    var genreFilter: XCUIElement {
        buttons["discover.genreFilter"]
    }

    /// Opens the genre menu and picks `title`.
    func tapGenre(_ title: String) {
        genreFilter.tap()
        let option = buttons[title].firstMatch
        XCTAssertTrue(option.waitForExistence(timeout: 5))
        option.tap()
    }
}
