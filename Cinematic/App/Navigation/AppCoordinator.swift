import CinematicDomain
import SwiftUI

/// The root coordinator. Owns one `TabCoordinator` per tab and tracks the
/// selected tab. Switching tabs preserves each tab's navigation state.
@MainActor
@Observable
final class AppCoordinator {
    var selectedTab: AppTab = .discover

    private var coordinators: [AppTab: TabCoordinator]

    init() {
        coordinators = Dictionary(
            uniqueKeysWithValues: AppTab.allCases.map { ($0, TabCoordinator(tab: $0)) },
        )
    }

    func coordinator(for tab: AppTab) -> TabCoordinator {
        if let existing = coordinators[tab] {
            return existing
        }
        let created = TabCoordinator(tab: tab)
        coordinators[tab] = created
        return created
    }

    /// Routes `cinematic://movie/<id>` to the detail screen.
    func handle(_ url: URL) {
        guard
            url.scheme == "cinematic",
            url.host() == "movie",
            let id = url.pathComponents.dropFirst().first
        else { return }
        selectedTab = .discover
        coordinator(for: .discover).push(.movieDetail(id: Movie.ID(id)))
    }
}
