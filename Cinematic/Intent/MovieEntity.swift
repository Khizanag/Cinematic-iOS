import AppIntents
import CinematicDomain
import Foundation

/// A movie as Siri, Shortcuts and Spotlight see it.
///
/// A projection of the domain `Movie` for the system, the same way a view
/// state is a projection for a screen; the domain type stays free of
/// framework conformances.
struct MovieEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "intent.movie.type")
    static let defaultQuery = MovieEntityQuery()

    let id: String

    @Property(title: "intent.movie.title")
    var title: String

    @Property(title: "intent.movie.director")
    var directorName: String?

    let posterURL: URL?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: directorName.map { "\($0)" },
            image: posterURL.map { DisplayRepresentation.Image(url: $0) },
        )
    }

    init(movie: Movie) {
        id = movie.id.rawValue
        posterURL = movie.posterURL
        title = movie.title
        directorName = movie.directorName
    }
}
