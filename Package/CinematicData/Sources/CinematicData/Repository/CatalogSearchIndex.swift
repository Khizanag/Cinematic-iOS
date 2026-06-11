import CinematicDomain
import Foundation

/// Short-lived in-memory copy of the full catalog that local search filters.
///
/// An `actor` because several searches can race; five minutes keeps charts
/// reasonably current without refetching on every keystroke.
actor CatalogSearchIndex {
    private var catalog: [Movie]?
    private var storedAt: Date?
    private let lifetime: TimeInterval = 300

    func freshCatalog() -> [Movie]? {
        guard
            let catalog,
            let storedAt,
            Date.now.timeIntervalSince(storedAt) < lifetime
        else { return nil }
        return catalog
    }

    func store(_ movies: [Movie]) {
        catalog = movies
        storedAt = .now
    }
}
