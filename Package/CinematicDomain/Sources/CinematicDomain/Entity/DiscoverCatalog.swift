/// Content of the discover screen: the overall chart plus one row per genre.
public struct DiscoverCatalog: Equatable, Sendable {
    public struct GenreSection: Identifiable, Equatable, Sendable {
        public let genre: MovieGenre
        public let movies: [Movie]

        public var id: MovieGenre { genre }

        public init(genre: MovieGenre, movies: [Movie]) {
            self.genre = genre
            self.movies = movies
        }
    }

    public let featured: [Movie]
    public let sections: [GenreSection]

    public init(featured: [Movie], sections: [GenreSection]) {
        self.featured = featured
        self.sections = sections
    }
}
