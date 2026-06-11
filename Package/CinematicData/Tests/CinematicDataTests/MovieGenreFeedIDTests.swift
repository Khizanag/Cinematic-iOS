@testable import CinematicData
import CinematicDomain
import Testing

struct MovieGenreFeedIDTests {
    @Test("Every genre maps to a unique feed identifier")
    func feedGenreIDsAreUnique() {
        let ids = MovieGenre.allCases.map(\.feedGenreID)
        #expect(Set(ids).count == ids.count)
    }
}
