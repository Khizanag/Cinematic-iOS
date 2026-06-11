@testable import CinematicData
import CinematicDomain
import Foundation
import Testing

struct MovieMapperTests {
    @Test("Feed entries map onto the domain entity")
    func mapsFeedEntry() throws {
        let feed = try decodeFeed(SampleJSON.feedWithTwoEntries)
        let entry = try #require(feed.feed.entries.first)

        let movie = MovieMapper.movie(from: entry)

        #expect(movie.id == Movie.ID("1895068395"))
        #expect(movie.title == "Michael")
        #expect(movie.directorName == "Antoine Fuqua")
        #expect(movie.genreName == "Drama")
        #expect(movie.posterURL?.absoluteString == "https://example.com/image/113x170bb.png")
        #expect(movie.price == Price(amount: Decimal(string: "24.99") ?? .zero, currencyCode: "USD"))
        #expect(movie.releaseDate != nil)
    }

    @Test("The large poster swaps the artwork rendition component")
    func rewritesLargePoster() throws {
        let feed = try decodeFeed(SampleJSON.feedWithTwoEntries)
        let entry = try #require(feed.feed.entries.first)

        let movie = MovieMapper.movie(from: entry)

        #expect(movie.largePosterURL?.absoluteString == "https://example.com/image/600x600bb.jpg")
    }

    @Test("Lookup results map onto the detail aggregate")
    func mapsLookupResult() throws {
        let response = try JSONDecoder.iso8601.decode(LookupResponseDTO.self, from: SampleJSON.lookupResponse)
        let dto = try #require(response.results.first)

        let details = try #require(MovieMapper.movieDetails(from: dto))

        #expect(details.movie.id == Movie.ID("1895068395"))
        #expect(details.movie.summary == "Short summary.")
        #expect(details.fullSummary == "The long, complete summary.")
        #expect(details.advisoryRating == "PG-13")
        #expect(details.duration == .milliseconds(139_204))
        #expect(details.trailerURL?.absoluteString == "https://video.example.com/preview.m4v")
        #expect(details.storeURL != nil)
    }

    @Test("A lookup result without a title cannot become a movie")
    func lookupWithoutTitleIsDropped() throws {
        let json = Data(#"{"resultCount": 1, "results": [{"trackId": 1}]}"#.utf8)
        let response = try JSONDecoder.iso8601.decode(LookupResponseDTO.self, from: json)
        let dto = try #require(response.results.first)

        #expect(MovieMapper.movieDetails(from: dto) == nil)
    }
}

// MARK: - ArtworkURL
struct ArtworkURLTests {
    @Test("Rendition components are replaced with the requested size")
    func rewritesRendition() {
        let url = URL(string: "https://example.com/asset/39x60bb.png")

        let resized = ArtworkURL.resized(url, to: 600)

        #expect(resized?.absoluteString == "https://example.com/asset/600x600bb.jpg")
    }

    @Test("URLs without a rendition component pass through unchanged")
    func passesThroughOtherURLs() {
        let url = URL(string: "https://example.com/poster.png")

        #expect(ArtworkURL.resized(url, to: 600) == url)
        #expect(ArtworkURL.resized(nil, to: 600) == nil)
    }
}

// MARK: - Helpers
private extension MovieMapperTests {
    func decodeFeed(_ data: Data) throws -> TopMoviesFeedDTO {
        try JSONDecoder.iso8601.decode(TopMoviesFeedDTO.self, from: data)
    }
}

// MARK: - Decoder fixture
extension JSONDecoder {
    static var iso8601: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
