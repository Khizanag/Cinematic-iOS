import AppIntents
import CinematicDomain

/// The catalog genres as a Shortcuts parameter.
///
/// App Intents reads case names at build time, so they're spelled out here
/// rather than derived from `MovieGenre`.
enum GenreAppEnum: String, AppEnum {
    case actionAndAdventure
    case comedy
    case drama
    case horror
    case kidsAndFamily
    case sciFiAndFantasy
    case thriller

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "intent.genre.type")

    static let caseDisplayRepresentations: [GenreAppEnum: DisplayRepresentation] = [
        .actionAndAdventure: DisplayRepresentation(
            title: "genre.actionAndAdventure",
            image: .init(systemName: "flame"),
        ),
        .comedy: DisplayRepresentation(title: "genre.comedy", image: .init(systemName: "face.smiling")),
        .drama: DisplayRepresentation(title: "genre.drama", image: .init(systemName: "theatermasks")),
        .horror: DisplayRepresentation(title: "genre.horror", image: .init(systemName: "eye")),
        .kidsAndFamily: DisplayRepresentation(
            title: "genre.kidsAndFamily",
            image: .init(systemName: "figure.2.and.child.holdinghands"),
        ),
        .sciFiAndFantasy: DisplayRepresentation(title: "genre.sciFiAndFantasy", image: .init(systemName: "sparkles")),
        .thriller: DisplayRepresentation(title: "genre.thriller", image: .init(systemName: "bolt")),
    ]

    var genre: MovieGenre {
        switch self {
        case .actionAndAdventure: .actionAndAdventure
        case .comedy: .comedy
        case .drama: .drama
        case .horror: .horror
        case .kidsAndFamily: .kidsAndFamily
        case .sciFiAndFantasy: .sciFiAndFantasy
        case .thriller: .thriller
        }
    }
}
