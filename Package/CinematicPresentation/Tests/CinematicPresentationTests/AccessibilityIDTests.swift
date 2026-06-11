import CinematicPresentation
import Testing

struct AccessibilityIDTests {
    @Test("Accessibility identifiers are unique")
    func identifiersAreUnique() {
        let ids = [
            AccessibilityID.discoverList,
            AccessibilityID.searchResults,
            AccessibilityID.favoritesList,
            AccessibilityID.movieDetail,
        ]
        #expect(Set(ids).count == ids.count)
    }
}
