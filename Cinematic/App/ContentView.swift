import CinematicDomain
import CinematicPresentation
import SwiftUI

/// Root view: one `Tab` per `AppTab`, each hosting its own coordinated stack.
/// This is also where feature events meet navigation — the factories and
/// closures here are the only glue between the two.
struct ContentView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        @Bindable var coordinator = coordinator
        return TabView(selection: $coordinator.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                Tab(tab.title, systemImage: tab.systemImage, value: tab, role: tab.role) {
                    CoordinatedNavigationStack(coordinator: coordinator.coordinator(for: tab)) {
                        rootView(for: tab)
                    }
                }
            }
        }
    }
}

// MARK: - Tab roots
private extension ContentView {
    @ViewBuilder
    func rootView(for tab: AppTab) -> some View {
        switch tab {
        case .discover:
            DiscoverView(fetchDiscoverCatalog: dependencies.fetchDiscoverCatalog) { movie in
                push(.movieDetail(id: movie.id), on: .discover)
            }
            .toolbar { aboutButton }
        case .search:
            SearchView(searchMovies: dependencies.searchMovies) { movie in
                push(.movieDetail(id: movie.id), on: .search)
            }
        case .favorites:
            FavoritesView(
                observeFavorites: dependencies.observeFavorites,
                toggleFavorite: dependencies.toggleFavorite,
            ) { movie in
                push(.movieDetail(id: movie.id), on: .favorites)
            }
        }
    }

    var aboutButton: some ToolbarContent {
        ToolbarItem(placement: .secondaryAction) {
            Button {
                coordinator.coordinator(for: .discover).present(.about)
            } label: {
                Image(systemName: "info.circle")
            }
            .accessibilityLabel(Text("about.title"))
        }
    }
}

// MARK: - Actions
private extension ContentView {
    func push(_ screen: Screen, on tab: AppTab) {
        coordinator.coordinator(for: tab).push(screen)
    }
}
