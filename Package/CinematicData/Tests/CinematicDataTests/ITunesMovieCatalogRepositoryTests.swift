@testable import CinematicData
import CinematicDomain
import Foundation
import Testing

/// Serialized: every test in this suite stubs the same fixed feed URLs.
@Suite(.serialized)
struct ITunesMovieCatalogRepositoryTests {
    private let repository = ITunesMovieCatalogRepository(
        client: APIClient(session: StubURLProtocol.makeSession()),
    )

    @Test("Search filters the combined catalog case-insensitively")
    func searchMatchesCaseInsensitively() async throws {
        stubCatalog()

        let results = try await repository.searchMovies(matching: "michael")

        #expect(results.map(\.title) == ["Michael"])
    }

    @Test("Search ranks title prefix matches before contains matches")
    func searchRanksPrefixFirst() async throws {
        stubCatalog()

        let results = try await repository.searchMovies(matching: "dune")

        #expect(results.map(\.title) == ["Dune: Part Three", "Return to Dune"])
    }

    @Test("Movies charting in several feeds collapse to one result")
    func duplicatesCollapse() async throws {
        stubCatalog()

        let results = try await repository.searchMovies(matching: "Hail")

        #expect(results.count == 1)
    }

    @Test("The catalog is fetched once and reused for following searches")
    func catalogIsCachedBetweenSearches() async throws {
        stubCatalog()
        let topURL = ITunesEndpoint.topMovies(limit: 50).url
        let before = StubURLProtocol.requestCount(for: topURL)

        _ = try await repository.searchMovies(matching: "dune")
        _ = try await repository.searchMovies(matching: "michael")

        #expect(StubURLProtocol.requestCount(for: topURL) == before + 1)
    }

    @Test("Details surface notFound for empty lookups")
    func emptyLookupIsNotFound() async {
        let id = Movie.ID("99")
        StubURLProtocol.setStub(
            .success((200, SampleJSON.emptyLookupResponse)),
            for: ITunesEndpoint.lookup(id: id.rawValue).url,
        )

        await #expect(throws: MovieError.notFound) {
            try await repository.movieDetails(for: id)
        }
    }

    @Test("Details map the lookup payload")
    func detailsMapLookup() async throws {
        let id = Movie.ID("1895068395")
        StubURLProtocol.setStub(
            .success((200, SampleJSON.lookupResponse)),
            for: ITunesEndpoint.lookup(id: id.rawValue).url,
        )

        let details = try await repository.movieDetails(for: id)

        #expect(details.movie.title == "Michael")
        #expect(details.advisoryRating == "PG-13")
    }
}

// MARK: - Helpers
private extension ITunesMovieCatalogRepositoryTests {
    /// Top chart: Michael, Dune: Part Three, Return to Dune. Action genre
    /// repeats Project Hail Mary; the other genres are empty.
    func stubCatalog() {
        let top = makeFeedJSON(entryJSONs: [
            makeFeedEntryJSON(id: "1", name: "Michael"),
            makeFeedEntryJSON(id: "2", name: "Dune: Part Three"),
            makeFeedEntryJSON(id: "3", name: "Return to Dune"),
            makeFeedEntryJSON(id: "4", name: "Project Hail Mary"),
        ])
        StubURLProtocol.setStub(.success((200, top)), for: ITunesEndpoint.topMovies(limit: 50).url)

        for genre in MovieGenre.allCases {
            let entries = genre == .actionAndAdventure
                ? [makeFeedEntryJSON(id: "4", name: "Project Hail Mary", genre: "Action & Adventure")]
                : []
            let url = ITunesEndpoint.topMoviesInGenre(genreID: genre.feedGenreID, limit: 50).url
            StubURLProtocol.setStub(.success((200, makeFeedJSON(entryJSONs: entries))), for: url)
        }
    }
}
