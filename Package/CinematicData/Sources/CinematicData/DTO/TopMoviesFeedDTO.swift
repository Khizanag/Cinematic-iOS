import Foundation

/// The iTunes RSS "top movies" feed, exactly as Apple ships it: `im:`-prefixed
/// keys, every scalar wrapped in `{"label": …}`, and an `entry` that is an
/// array for many results, a bare object for one, and absent for none.
///
/// DTOs mirror the wire format and nothing else — mapping to domain entities
/// happens in `MovieMapper`, so the weirdness stops at this file.
struct TopMoviesFeedDTO: Decodable {
    let feed: Feed

    struct Feed: Decodable {
        let entries: [FeedEntryDTO]

        private enum CodingKeys: String, CodingKey {
            case entry
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard container.contains(.entry) else {
                entries = []
                return
            }
            // A single result arrives as a bare object. Probe for that shape
            // first; otherwise decode strictly as an array so malformed
            // entries surface as real decoding errors instead of vanishing.
            if let single = try? container.decode(FeedEntryDTO.self, forKey: .entry) {
                entries = [single]
            } else {
                entries = try container.decode([FeedEntryDTO].self, forKey: .entry)
            }
        }
    }
}

/// One movie entry of the RSS feed.
///
/// Required fields (`im:name`, `title`, `id`) fail the decode when absent —
/// that means the feed contract changed and we want to know. Everything else
/// is optional by design: real feeds drop fields all the time.
struct FeedEntryDTO: Decodable {
    let name: Label
    let title: Label
    let id: Identifier
    let images: [Image]?
    let summary: Label?
    let artist: Label?
    let category: Category?
    let releaseDate: ReleaseDate?
    let price: PriceTag?

    private enum CodingKeys: String, CodingKey {
        case name = "im:name"
        case title
        case id
        case images = "im:image"
        case summary
        case artist = "im:artist"
        case category
        case releaseDate = "im:releaseDate"
        case price = "im:price"
    }

    struct Label: Decodable {
        let label: String
    }

    /// `"id": {"label": …, "attributes": {"im:id": "…"}}` — the only part the
    /// app needs is the nested attribute, so decoding flattens it with a
    /// nested container.
    struct Identifier: Decodable {
        let value: String

        private enum CodingKeys: String, CodingKey {
            case attributes
        }

        private enum AttributeKeys: String, CodingKey {
            case id = "im:id"
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let attributes = try container.nestedContainer(keyedBy: AttributeKeys.self, forKey: .attributes)
            value = try attributes.decode(String.self, forKey: .id)
        }
    }

    struct Image: Decodable {
        let label: String
    }

    struct Category: Decodable {
        let attributes: Attributes?

        struct Attributes: Decodable {
            let term: String
        }
    }

    struct ReleaseDate: Decodable {
        let label: Date?
    }

    struct PriceTag: Decodable {
        let attributes: Attributes?

        struct Attributes: Decodable {
            let amount: String
            let currency: String
        }
    }
}
