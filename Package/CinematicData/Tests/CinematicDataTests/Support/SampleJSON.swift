import Foundation

/// Canned wire payloads. The rich literals mirror real responses
/// field-for-field; the builders generate minimal valid entries for
/// behavioral tests.
enum SampleJSON {
    static let feedWithTwoEntries = Data("""
    {"feed": {"entry": [
      {
        "im:name": {"label": "Michael"},
        "im:image": [
          {"label": "https://example.com/image/39x60bb.png", "attributes": {"height": "60"}},
          {"label": "https://example.com/image/113x170bb.png", "attributes": {"height": "170"}}
        ],
        "summary": {"label": "A film about a legend."},
        "im:price": {"label": "$24.99", "attributes": {"amount": "24.99", "currency": "USD"}},
        "title": {"label": "Michael - Antoine Fuqua"},
        "id": {"label": "https://itunes.apple.com/us/movie/michael/id1895068395?uo=2", "attributes": {"im:id": "1895068395"}},
        "im:artist": {"label": "Antoine Fuqua"},
        "category": {"attributes": {"im:id": "4406", "term": "Drama", "label": "Drama"}},
        "im:releaseDate": {"label": "2026-04-24T00:00:00-07:00", "attributes": {"label": "April 24, 2026"}}
      },
      {
        "im:name": {"label": "Hokum"},
        "title": {"label": "Hokum - Director"},
        "id": {"label": "https://itunes.apple.com/us/movie/hokum/id42?uo=2", "attributes": {"im:id": "42"}}
      }
    ]}}
    """.utf8)

    static let feedWithSingleEntry = Data("""
    {"feed": {"entry":
      {
        "im:name": {"label": "Lonely"},
        "title": {"label": "Lonely - Director"},
        "id": {"label": "https://example.com/id7", "attributes": {"im:id": "7"}}
      }
    }}
    """.utf8)

    static let feedWithNoEntries = Data("""
    {"feed": {"updated": {"label": "2026-06-11T05:55:52-07:00"}}}
    """.utf8)

    static let lookupResponse = Data("""
    {"resultCount": 1, "results": [
      {
        "wrapperType": "track",
        "kind": "feature-movie",
        "trackId": 1895068395,
        "artistName": "Antoine Fuqua",
        "trackName": "Michael",
        "trackViewUrl": "https://itunes.apple.com/us/movie/michael/id1895068395?uo=4",
        "previewUrl": "https://video.example.com/preview.m4v",
        "artworkUrl100": "https://example.com/image/100x100bb.jpg",
        "releaseDate": "2026-04-24T07:00:00Z",
        "primaryGenreName": "Drama",
        "contentAdvisoryRating": "PG-13",
        "trackTimeMillis": 139204,
        "trackPrice": 24.99,
        "currency": "USD",
        "shortDescription": "Short summary.",
        "longDescription": "The long, complete summary."
      }
    ]}
    """.utf8)

    static let emptyLookupResponse = Data("""
    {"resultCount": 0, "results": []}
    """.utf8)
}

// MARK: - Builders
func makeFeedEntryJSON(id: String, name: String, genre: String = "Drama") -> String {
    """
    {
      "im:name": {"label": "\(name)"},
      "title": {"label": "\(name) - Director"},
      "id": {"label": "https://example.com/id\(id)", "attributes": {"im:id": "\(id)"}},
      "category": {"attributes": {"term": "\(genre)"}}
    }
    """
}

func makeFeedJSON(entryJSONs: [String]) -> Data {
    Data("""
    {"feed": {"entry": [\(entryJSONs.joined(separator: ","))]}}
    """.utf8)
}
