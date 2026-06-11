import CinematicDesign
import CinematicDomain
import MVIKit
import SwiftUI

/// One movie, in full: poster, metadata, summary, trailer, store link, and
/// the favorite toggle.
public struct MovieDetailView: View {
    @State private var store: Store<MovieDetailReducer>

    private let onPlayTrailer: (URL) -> Void

    public init(
        movieID: Movie.ID,
        fetchMovieDetails: FetchMovieDetailsUseCase,
        toggleFavorite: ToggleFavoriteUseCase,
        observeFavorites: ObserveFavoritesUseCase,
        onPlayTrailer: @escaping (URL) -> Void,
    ) {
        _store = State(initialValue: Store(
            initialState: MovieDetailReducer.State(movieID: movieID),
            reducer: MovieDetailReducer(
                fetchMovieDetails: fetchMovieDetails,
                toggleFavorite: toggleFavorite,
                observeFavorites: observeFavorites,
            ),
        ))
        self.onPlayTrailer = onPlayTrailer
    }

    public var body: some View {
        content
            .background(DesignSystem.Color.background)
            .navigationTitle(store.state.details.value?.movie.title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task { store.send(.task) }
    }
}

// MARK: - Toolbar
private extension MovieDetailView {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if store.state.details.value != nil {
            ToolbarItem(placement: .primaryAction) {
                FavoriteButton(
                    isFavorite: store.state.isFavorite,
                    label: favoriteLabel,
                ) {
                    store.send(.favoriteTapped)
                }
            }
        }
    }

    var favoriteLabel: String {
        store.state.isFavorite
            ? String(localized: "detail.unfavorite", bundle: .module)
            : String(localized: "detail.favorite", bundle: .module)
    }
}

// MARK: - Sub-views
private extension MovieDetailView {
    @ViewBuilder
    var content: some View {
        switch store.state.details {
        case .idle, .loading:
            MovieDetailSkeleton()
        case let .loaded(details):
            loadedContent(details)
        case let .failed(error):
            ErrorStateView(error: error) { store.send(.retry) }
        }
    }

    func loadedContent(_ details: MovieDetails) -> some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                header(details)
                actions(details)
                summary(details)
                footer(details)
            }
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityIdentifier(AccessibilityID.movieDetail)
    }

    func header(_ details: MovieDetails) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            PosterImage(
                url: details.movie.largePosterURL ?? details.movie.posterURL,
                width: DesignSystem.Size.Poster.featured,
            )
            .designShadow(.elevated)

            Text(details.movie.title)
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)

            if let directorName = details.movie.directorName {
                Text("detail.directedBy \(directorName)", bundle: .module)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            if let metadataLine = details.metadataLine {
                Text(metadataLine)
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func actions(_ details: MovieDetails) -> some View {
        if let trailerURL = details.trailerURL {
            Button {
                onPlayTrailer(trailerURL)
            } label: {
                Label {
                    Text("detail.playTrailer", bundle: .module)
                } icon: {
                    Image(systemName: "play.fill")
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    func summary(_ details: MovieDetails) -> some View {
        if let text = details.fullSummary ?? details.movie.summary {
            Text(text)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    func footer(_ details: MovieDetails) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            if let price = details.movie.formattedPrice {
                Text(price)
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
            if let storeURL = details.storeURL {
                Link(destination: storeURL) {
                    Label {
                        Text("detail.viewInStore", bundle: .module)
                    } icon: {
                        Image(systemName: "arrow.up.right.square")
                    }
                }
                .font(DesignSystem.Font.subheadline)
            }
        }
    }
}

#Preview {
    let repository = PreviewMovieCatalogRepository()
    let favorites = PreviewFavoritesRepository()
    return NavigationStack {
        MovieDetailView(
            movieID: PreviewCatalog.movies[0].id,
            fetchMovieDetails: FetchMovieDetailsUseCase(repository: repository),
            toggleFavorite: ToggleFavoriteUseCase(repository: favorites),
            observeFavorites: ObserveFavoritesUseCase(repository: favorites),
            onPlayTrailer: { _ in },
        )
    }
}
