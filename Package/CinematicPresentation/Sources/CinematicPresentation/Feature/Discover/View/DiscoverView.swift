import CinematicDesign
import CinematicDomain
import MVIKit
import SwiftUI

/// The home screen: featured chart plus one horizontal row per genre.
///
/// Navigation-agnostic by design — it reports selection through
/// `onSelectMovie` and the composition root decides where that leads.
public struct DiscoverView: View {
    @State private var store: Store<DiscoverReducer>

    private let onSelectMovie: (Movie) -> Void

    public init(
        fetchDiscoverCatalog: FetchDiscoverCatalogUseCase,
        onSelectMovie: @escaping (Movie) -> Void,
    ) {
        _store = State(initialValue: Store(
            initialState: DiscoverReducer.State(),
            reducer: DiscoverReducer(fetchDiscoverCatalog: fetchDiscoverCatalog),
        ))
        self.onSelectMovie = onSelectMovie
    }

    public var body: some View {
        content
            .background(DesignSystem.Color.background)
            .navigationTitle(Text("discover.title", bundle: .module))
            .task { store.send(.task) }
    }
}

// MARK: - Sub-views
private extension DiscoverView {
    @ViewBuilder
    var content: some View {
        switch store.state.catalog {
        case .idle, .loading:
            DiscoverSkeleton()
        case let .loaded(catalog):
            loadedContent(catalog)
        case let .failed(error):
            ErrorStateView(error: error) { store.send(.retry) }
        }
    }

    func loadedContent(_ catalog: DiscoverCatalog) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                featuredSection(catalog.featured)
                ForEach(catalog.sections) { section in
                    genreSection(section)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .accessibilityIdentifier(AccessibilityID.discoverList)
    }

    func featuredSection(_ movies: [Movie]) -> some View {
        section(
            title: String(localized: "discover.topMovies", bundle: .module),
            movies: movies,
            posterWidth: DesignSystem.Size.Poster.featured,
        )
    }

    func genreSection(_ genreSection: DiscoverCatalog.GenreSection) -> some View {
        section(
            title: genreSection.genre.displayName,
            movies: genreSection.movies,
            posterWidth: DesignSystem.Size.Poster.row,
        )
    }

    func section(title: String, movies: [Movie], posterWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeader(title: title)
                .padding(.horizontal, DesignSystem.Spacing.md)
            posterRow(movies, posterWidth: posterWidth)
        }
    }

    func posterRow(_ movies: [Movie], posterWidth: CGFloat) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                ForEach(movies) { movie in
                    movieButton(movie, posterWidth: posterWidth)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .scrollIndicators(.hidden)
    }

    func movieButton(_ movie: Movie, posterWidth: CGFloat) -> some View {
        Button {
            onSelectMovie(movie)
        } label: {
            MovieCard(
                title: movie.title,
                caption: movie.genreName,
                posterURL: movie.posterURL,
                width: posterWidth,
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        DiscoverView(
            fetchDiscoverCatalog: FetchDiscoverCatalogUseCase(repository: PreviewMovieCatalogRepository()),
            onSelectMovie: { _ in },
        )
    }
}
