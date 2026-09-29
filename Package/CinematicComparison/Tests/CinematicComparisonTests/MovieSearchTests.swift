@testable import CinematicComparison
import CinematicDomain
import Testing

/// MV's model holds the parts of the contract that live in the model. Debounce
/// and switch-latest belong to the view's `.task(id:)`, so they are SwiftUI's
/// guarantee and only a UI test could check them. Here the test plays
/// SwiftUI's part and cancels the stale call itself.
struct MovieSearchTests {
    @Test("A short query resets to idle without a request")
    func shortQueryResets() async {
        let repository = ScriptedCatalogRepository()
        let search = MovieSearch(searchMovies: SearchMoviesUseCase(repository: repository))

        await search.search(for: " v ")

        #expect(await repository.receivedQueries.isEmpty)
        #expect(search.results == .idle)
    }

    @Test("A cancelled call never overwrites a newer one")
    func cancelledCallIsDropped() async {
        let repository = ScriptedCatalogRepository(delays: ["du": .milliseconds(150)])
        let search = MovieSearch(searchMovies: SearchMoviesUseCase(repository: repository))

        let stale = Task { await search.search(for: "du") }
        await waitUntil { await repository.receivedQueries == ["du"] }
        stale.cancel()
        await search.search(for: "dune")
        await stale.value

        #expect(search.results == .loaded([ScriptedCatalogRepository.movie(for: "dune")]))
    }

    @Test("Failures surface as the typed domain error")
    func failureIsTyped() async {
        let repository = ScriptedCatalogRepository(failure: .timedOut)
        let search = MovieSearch(searchMovies: SearchMoviesUseCase(repository: repository))

        await search.search(for: "voyage")

        #expect(search.results == .failed(.timedOut))
    }
}
