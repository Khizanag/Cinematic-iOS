import CinematicDomain
import Testing

struct FetchDiscoverCatalogUseCaseTests {
    @Test("Genre sections keep the declared genre order")
    func sectionsKeepDeclaredOrder() async throws {
        var stub = StubMovieCatalogRepository()
        stub.topMoviesResult = .success([makeMovie(id: "top")])
        for genre in MovieGenre.allCases {
            stub.genreResults[genre] = .success([makeMovie(id: genre.rawValue)])
        }

        let catalog = try await FetchDiscoverCatalogUseCase(repository: stub).execute()

        #expect(catalog.featured == [makeMovie(id: "top")])
        #expect(catalog.sections.map(\.genre) == MovieGenre.allCases)
    }

    @Test("A failing genre row is dropped instead of failing the screen")
    func failingGenreIsDropped() async throws {
        var stub = StubMovieCatalogRepository()
        stub.topMoviesResult = .success([makeMovie(id: "top")])
        for genre in MovieGenre.allCases {
            stub.genreResults[genre] = .success([makeMovie(id: genre.rawValue)])
        }
        stub.genreResults[.comedy] = .failure(.timedOut)

        let catalog = try await FetchDiscoverCatalogUseCase(repository: stub).execute()

        #expect(!catalog.sections.map(\.genre).contains(.comedy))
        #expect(catalog.sections.count == MovieGenre.allCases.count - 1)
    }

    @Test("Empty genre rows are dropped")
    func emptyGenreIsDropped() async throws {
        var stub = StubMovieCatalogRepository()
        stub.topMoviesResult = .success([makeMovie(id: "top")])
        stub.genreResults[.drama] = .success([makeMovie(id: "drama")])
        stub.genreResults[.horror] = .success([])

        let catalog = try await FetchDiscoverCatalogUseCase(repository: stub).execute()

        #expect(catalog.sections.map(\.genre) == [.drama])
    }

    @Test("A failing featured chart fails the whole load")
    func failingFeaturedThrows() async {
        var stub = StubMovieCatalogRepository()
        stub.topMoviesResult = .failure(.offline)
        let useCase = FetchDiscoverCatalogUseCase(repository: stub)

        await #expect(throws: MovieError.offline) {
            try await useCase.execute()
        }
    }
}
