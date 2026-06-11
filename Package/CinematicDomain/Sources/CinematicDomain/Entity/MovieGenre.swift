/// The catalog genres the app can browse.
///
/// Cases are semantic. Mapping them to a concrete API's genre identifiers is
/// a data-layer detail and never appears above it.
public enum MovieGenre: String, CaseIterable, Sendable {
    case actionAndAdventure
    case comedy
    case drama
    case horror
    case kidsAndFamily
    case sciFiAndFantasy
    case thriller
}
