import CinematicDomain
import Testing

struct MovieGenreTests {
    @Test("Genres are distinct and non-empty")
    func genreCases() {
        #expect(!MovieGenre.allCases.isEmpty)
        #expect(Set(MovieGenre.allCases).count == MovieGenre.allCases.count)
    }
}
