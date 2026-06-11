@testable import CinematicData
import Foundation
import Testing

struct FeedDecodingTests {
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    @Test("A multi-entry feed decodes every field the app reads")
    func multiEntryFeed() throws {
        let feed = try decoder.decode(TopMoviesFeedDTO.self, from: SampleJSON.feedWithTwoEntries)
        let first = try #require(feed.feed.entries.first)

        #expect(feed.feed.entries.count == 2)
        #expect(first.name.label == "Michael")
        #expect(first.id.value == "1895068395")
        #expect(first.artist?.label == "Antoine Fuqua")
        #expect(first.category?.attributes?.term == "Drama")
        #expect(first.summary?.label == "A film about a legend.")
        #expect(first.images?.last?.label == "https://example.com/image/113x170bb.png")
        #expect(first.price?.attributes?.amount == "24.99")
        #expect(first.releaseDate?.label != nil)
    }

    @Test("Optional fields may be absent without failing the entry")
    func sparseEntry() throws {
        let feed = try decoder.decode(TopMoviesFeedDTO.self, from: SampleJSON.feedWithTwoEntries)
        let sparse = try #require(feed.feed.entries.last)

        #expect(sparse.name.label == "Hokum")
        #expect(sparse.artist == nil)
        #expect(sparse.images == nil)
        #expect(sparse.price == nil)
    }

    @Test("A single result arrives as a bare object, not an array")
    func singleEntryFeed() throws {
        let feed = try decoder.decode(TopMoviesFeedDTO.self, from: SampleJSON.feedWithSingleEntry)

        #expect(feed.feed.entries.map(\.name.label) == ["Lonely"])
    }

    @Test("An empty feed has no entry key at all")
    func emptyFeed() throws {
        let feed = try decoder.decode(TopMoviesFeedDTO.self, from: SampleJSON.feedWithNoEntries)

        #expect(feed.feed.entries.isEmpty)
    }

    @Test("A lookup response decodes the detail fields")
    func lookupResponse() throws {
        let response = try decoder.decode(LookupResponseDTO.self, from: SampleJSON.lookupResponse)
        let movie = try #require(response.results.first)

        #expect(response.resultCount == 1)
        #expect(movie.trackID == 1_895_068_395)
        #expect(movie.trackName == "Michael")
        #expect(movie.contentAdvisoryRating == "PG-13")
        #expect(movie.trackTimeMillis == 139_204)
        #expect(movie.releaseDate != nil)
    }
}
