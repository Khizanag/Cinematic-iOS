@testable import CinematicComparison
import CinematicDomain
import Testing

/// One behavioural contract, held against every variant that owns its own
/// concurrency. The same test body passing for each is the claim that the
/// architectures are interchangeable in what the user sees.
struct SearchBehaviorTests {
    @Test("Keystrokes collapse into one request for the final query", arguments: Variant.allCases)
    func keystrokesCollapse(variant: Variant) async {
        let repository = ScriptedCatalogRepository()
        let search = variant.makeDriver(repository)

        for query in ["v", "vo", "voy", "voyage"] {
            search.type(query)
        }
        await search.settle()

        #expect(await repository.receivedQueries == ["voyage"])
        #expect(search.results == .loaded([ScriptedCatalogRepository.movie(for: "voyage")]))
    }

    @Test("A short query resets to idle and cancels the pending search", arguments: Variant.allCases)
    func shortQueryCancels(variant: Variant) async {
        let repository = ScriptedCatalogRepository()
        let search = variant.makeDriver(repository)

        search.type("voyage")
        search.type("v")
        await search.settle()

        #expect(await repository.receivedQueries.isEmpty)
        #expect(search.results == .idle)
    }

    @Test("A stale response never overwrites a newer one", arguments: Variant.allCases)
    func staleResponseIsDropped(variant: Variant) async {
        let repository = ScriptedCatalogRepository(delays: ["du": .milliseconds(150)])
        let search = variant.makeDriver(repository)

        search.type("du")
        await waitUntil { await repository.receivedQueries == ["du"] }
        search.type("dune")
        await search.settle()
        await waitUntil { await repository.answeredQueries.contains("du") }
        // Lets the stale caller resume on the main actor before asserting.
        try? await Task.sleep(for: .milliseconds(20))

        #expect(search.results == .loaded([ScriptedCatalogRepository.movie(for: "dune")]))
    }

    @Test("Failures surface as the typed domain error", arguments: Variant.allCases)
    func failureIsTyped(variant: Variant) async {
        let search = variant.makeDriver(ScriptedCatalogRepository(failure: .timedOut))

        search.type("voyage")
        await search.settle()

        #expect(search.results == .failed(.timedOut))
    }
}
