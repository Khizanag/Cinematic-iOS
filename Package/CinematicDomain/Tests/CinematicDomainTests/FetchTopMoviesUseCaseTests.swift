import CinematicDomain
import Testing

struct FetchTopMoviesUseCaseTests {
    @Test("Without a genre it returns the overall chart")
    func overallChart() async throws {
        var stub = StubMovieCatalogRepository()
        stub.topMoviesResult = .success([makeMovie(id: "1"), makeMovie(id: "2")])

        let movies = try await FetchTopMoviesUseCase(repository: stub).execute()

        #expect(movies.map(\.id.rawValue) == ["1", "2"])
    }

    @Test("With a genre it returns that genre's chart")
    func genreChart() async throws {
        var stub = StubMovieCatalogRepository()
        stub.topMoviesResult = .success([makeMovie(id: "1")])
        stub.genreResults[.horror] = .success([makeMovie(id: "7")])

        let movies = try await FetchTopMoviesUseCase(repository: stub).execute(genre: .horror)

        #expect(movies.map(\.id.rawValue) == ["7"])
    }

    @Test("The limit keeps the top of the chart")
    func limitKeepsTop() async throws {
        var stub = StubMovieCatalogRepository()
        stub.topMoviesResult = .success((1...5).map { makeMovie(id: "\($0)") })

        let movies = try await FetchTopMoviesUseCase(repository: stub).execute(limit: 3)

        #expect(movies.map(\.id.rawValue) == ["1", "2", "3"])
    }

    @Test("Repository failures propagate as domain errors")
    func failurePropagates() async {
        var stub = StubMovieCatalogRepository()
        stub.topMoviesResult = .failure(.offline)
        let useCase = FetchTopMoviesUseCase(repository: stub)

        await #expect(throws: MovieError.offline) {
            try await useCase.execute()
        }
    }
}
