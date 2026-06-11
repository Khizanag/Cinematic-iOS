import CinematicDomain
import Testing

struct SearchMoviesUseCaseTests {
    @Test(
        "Too-short queries short-circuit to empty without hitting the repository",
        arguments: ["", " ", "d", "  d  "],
    )
    func shortQueryShortCircuits(query: String) async throws {
        var stub = StubMovieCatalogRepository()
        stub.searchResult = .failure(.offline)

        let results = try await SearchMoviesUseCase(repository: stub).execute(query: query)

        #expect(results.isEmpty)
    }

    @Test("Valid queries delegate to the repository")
    func validQueryDelegates() async throws {
        var stub = StubMovieCatalogRepository()
        stub.searchResult = .success([makeMovie()])

        let results = try await SearchMoviesUseCase(repository: stub).execute(query: "du")

        #expect(results == [makeMovie()])
    }

    @Test("Repository failures propagate as domain errors")
    func repositoryFailurePropagates() async {
        var stub = StubMovieCatalogRepository()
        stub.searchResult = .failure(.timedOut)
        let useCase = SearchMoviesUseCase(repository: stub)

        await #expect(throws: MovieError.timedOut) {
            try await useCase.execute(query: "dune")
        }
    }
}
