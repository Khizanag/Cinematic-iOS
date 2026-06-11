import CinematicDomain

// MARK: - iTunes feed genre identifiers
extension MovieGenre {
    /// The numeric genre identifier used by the iTunes RSS movie feeds.
    /// The mapping is an API quirk that never leaks above the data layer.
    var feedGenreID: Int {
        switch self {
        case .actionAndAdventure: 4401
        case .comedy: 4404
        case .drama: 4406
        case .horror: 4408
        case .kidsAndFamily: 4410
        case .sciFiAndFantasy: 4413
        case .thriller: 4416
        }
    }
}
