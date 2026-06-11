import CinematicDomain
import Foundation

// MARK: - Display names
extension MovieGenre {
    var displayName: String {
        switch self {
        case .actionAndAdventure:
            String(localized: "genre.actionAndAdventure", bundle: .module)
        case .comedy:
            String(localized: "genre.comedy", bundle: .module)
        case .drama:
            String(localized: "genre.drama", bundle: .module)
        case .horror:
            String(localized: "genre.horror", bundle: .module)
        case .kidsAndFamily:
            String(localized: "genre.kidsAndFamily", bundle: .module)
        case .sciFiAndFantasy:
            String(localized: "genre.sciFiAndFantasy", bundle: .module)
        case .thriller:
            String(localized: "genre.thriller", bundle: .module)
        }
    }
}
