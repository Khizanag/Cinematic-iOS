import CinematicDesign
import CinematicDomain
import MVIKit
import SwiftUI

/// The user's saved movies, live-updated from the favorites stream.
public struct FavoritesView: View {
    private let onSelectMovie: (Movie) -> Void

    @State private var store: Store<FavoritesReducer>

    public init(
        observeFavorites: ObserveFavoritesUseCase,
        toggleFavorite: ToggleFavoriteUseCase,
        onSelectMovie: @escaping (Movie) -> Void,
    ) {
        _store = State(initialValue: Store(
            initialState: FavoritesReducer.State(),
            reducer: FavoritesReducer(
                observeFavorites: observeFavorites,
                toggleFavorite: toggleFavorite,
            ),
        ))
        self.onSelectMovie = onSelectMovie
    }

    public var body: some View {
        content
            .background(DesignSystem.Color.background)
            .navigationTitle(Text("favorites.title", bundle: .module))
            .task { store.send(.task) }
    }
}

// MARK: - Sub-views
private extension FavoritesView {
    @ViewBuilder
    var content: some View {
        switch store.state.favorites {
        case .idle, .loading:
            FavoritesSkeleton()
        case let .loaded(favorites) where favorites.isEmpty:
            emptyState
        case let .loaded(favorites):
            list(favorites)
        }
    }

    var emptyState: some View {
        ContentUnavailableView {
            Label(
                String(localized: "favorites.empty.title", bundle: .module),
                systemImage: "heart",
            )
        } description: {
            Text("favorites.empty.description", bundle: .module)
        }
    }

    func list(_ favorites: [Movie]) -> some View {
        List {
            ForEach(favorites) { movie in
                row(movie)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier(AccessibilityID.favoritesList)
    }

    func row(_ movie: Movie) -> some View {
        Button {
            onSelectMovie(movie)
        } label: {
            rowContent(movie)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            removeAction(movie)
        }
    }

    func rowContent(_ movie: Movie) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            PosterImage(url: movie.posterURL, width: DesignSystem.Size.Poster.thumbnail)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(movie.title)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(2)
                if let directorName = movie.directorName {
                    Text(directorName)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    func removeAction(_ movie: Movie) -> some View {
        Button(role: .destructive) {
            store.send(.removeTapped(movie))
        } label: {
            Label {
                Text("favorites.remove", bundle: .module)
            } icon: {
                Image(systemName: "heart.slash")
            }
        }
    }
}

#Preview {
    let favorites = PreviewFavoritesRepository(initialFavorites: Array(PreviewCatalog.movies.prefix(3)))
    return NavigationStack {
        FavoritesView(
            observeFavorites: ObserveFavoritesUseCase(repository: favorites),
            toggleFavorite: ToggleFavoriteUseCase(repository: favorites),
            onSelectMovie: { _ in },
        )
    }
}
