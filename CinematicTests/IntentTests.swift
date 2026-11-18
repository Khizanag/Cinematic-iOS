@testable import Cinematic
import CinematicDomain
import CinematicPresentation
import Testing

@MainActor
struct IntentTests {
    @Test("A movie entity carries the movie's id, title, director and poster")
    func entityMapsMovie() throws {
        let movie = try #require(PreviewCatalog.movies.first)

        let entity = MovieEntity(movie: movie)

        #expect(entity.id == movie.id.rawValue)
        #expect(entity.title == movie.title)
        #expect(entity.directorName == movie.directorName)
        #expect(entity.posterURL == movie.posterURL)
    }

    @Test("Suggestions list favorites first, then the chart without repeats")
    func suggestionsPutFavoritesFirst() async throws {
        let favorite = PreviewCatalog.movies[4]
        let query = MovieEntityQuery(dependencies: AppDependencies(
            catalog: PreviewMovieCatalogRepository(),
            favorites: PreviewFavoritesRepository(initialFavorites: [favorite]),
        ))

        let ids = try await query.suggestedEntities().map(\.id)

        let chartWithoutFavorite = PreviewCatalog.movies.map(\.id.rawValue).filter { $0 != favorite.id.rawValue }
        #expect(ids == [favorite.id.rawValue] + chartWithoutFavorite)
    }

    @Test("Typed text searches the catalog")
    func matchingSearches() async throws {
        let query = MovieEntityQuery(dependencies: .preview())

        let titles = try await query.entities(matching: "glass").map(\.title)

        #expect(titles == ["The Glass Garden"])
    }

    @Test("Lookup by id keeps the requested order and drops unknown ids")
    func lookupByID() async throws {
        let query = MovieEntityQuery(dependencies: .preview())

        let ids = try await query.entities(for: ["2", "missing", "1"]).map(\.id)

        #expect(ids == ["2", "1"])
    }

    @Test("Every genre option maps to the domain genre of the same name")
    func genreOptionsMatchDomain() {
        for option in GenreAppEnum.allCases {
            #expect(option.genre.rawValue == option.rawValue)
        }
        #expect(GenreAppEnum.allCases.count == MovieGenre.allCases.count)
    }

    @Test("Showing a movie opens its detail screen on the discover tab")
    func showMovieRoutes() {
        let coordinator = AppCoordinator()
        coordinator.selectedTab = .search

        coordinator.showMovie(Movie.ID("7"))

        #expect(coordinator.selectedTab == .discover)
        #expect(coordinator.coordinator(for: .discover).path == [.movieDetail(id: Movie.ID("7"))])
    }

    @Test("Showing a tab selects it without touching any stack")
    func showTabSelects() {
        let coordinator = AppCoordinator()

        coordinator.show(.favorites)

        #expect(coordinator.selectedTab == .favorites)
        #expect(coordinator.coordinator(for: .favorites).path.isEmpty)
    }
}
