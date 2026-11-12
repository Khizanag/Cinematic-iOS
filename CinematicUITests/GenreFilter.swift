import XCTest

// MARK: - Genre filter
extension XCUIApplication {
    /// Discover's genre menu in the navigation bar.
    var genreFilter: XCUIElement {
        buttons["discover.genreFilter"]
    }

    /// Opens the genre menu, picks `title`, and waits for the menu to close:
    /// the accessibility audit reads pixels, and a menu still fading out on a
    /// slow runner skews the contrast it measures for the content beneath.
    func tapGenre(_ title: String) {
        genreFilter.tap()
        let option = buttons[title].firstMatch
        XCTAssertTrue(option.waitForExistence(timeout: 5))
        option.tap()
        XCTAssertTrue(option.waitForNonExistence(timeout: 5))
    }
}
