import XCTest

// MARK: - Genre filter
extension XCUIApplication {
    /// Discover's genre chip bar.
    var genreFilter: XCUIElement {
        descendants(matching: .any)["discover.genreFilter"]
    }

    /// Taps a genre chip, first scrolling the bar until the chip is on screen:
    /// at accessibility text sizes most chips start past the trailing edge.
    ///
    /// Drags along the chip's own row rather than swiping the bar element:
    /// the bar's frame reaches up under the navigation bar, so a swipe at its
    /// center lands on the large title. Compares frames because `isHittable`
    /// throws for off-screen elements.
    func tapGenre(_ title: String) {
        let chip = genreFilter.buttons[title]
        let screen = frame
        for _ in 0..<6 where !screen.contains(chip.frame) {
            let isTrailing = chip.frame.midX > screen.midX
            let origin = coordinate(withNormalizedOffset: .zero)
            let start = origin.withOffset(CGVector(
                dx: screen.width * (isTrailing ? 0.8 : 0.2),
                dy: chip.frame.midY,
            ))
            let end = start.withOffset(CGVector(dx: screen.width * (isTrailing ? -0.6 : 0.6), dy: 0))
            start.press(forDuration: 0.05, thenDragTo: end)
        }
        chip.tap()
    }
}
