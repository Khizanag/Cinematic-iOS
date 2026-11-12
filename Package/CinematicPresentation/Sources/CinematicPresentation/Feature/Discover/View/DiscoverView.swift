import CinematicDesign
import CinematicDomain
import MVIKit
import SwiftUI

/// The home screen: featured chart plus one horizontal row per genre, or one
/// genre's full chart as a grid when the genre filter narrows it.
///
/// Navigation-agnostic by design — it reports selection through
/// `onSelectMovie` and the composition root decides where that leads.
public struct DiscoverView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let onSelectMovie: (Movie) -> Void

    @State private var store: Store<DiscoverReducer>
    @State private var scrollPosition = ScrollPosition(edge: .top)

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
            if let section = store.state.selectedSection {
                genreGrid(section.movies)
            } else {
                allRows(catalog)
            }
        }
        .scrollPosition($scrollPosition)
        .accessibilityIdentifier(AccessibilityID.discoverList)
        .refreshable { await refresh() }
        .safeAreaBar(edge: .top) { genreFilter }
        .onChange(of: store.state.selectedGenre) {
            scrollPosition.scrollTo(edge: .top)
        }
    }

    func allRows(_ catalog: DiscoverCatalog) -> some View {
        LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            featuredSection(catalog.featured)
            ForEach(catalog.sections) { section in
                genreSection(section)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.md)
    }

    func genreGrid(_ movies: [Movie]) -> some View {
        LazyVGrid(columns: gridColumns, alignment: .leading, spacing: DesignSystem.Spacing.md) {
            ForEach(movies) { movie in
                movieButton(movie, caption: movie.directorName, posterWidth: rowCardWidth)
            }
        }
        .padding(DesignSystem.Spacing.md)
    }

    var genreFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                FilterChip(
                    title: String(localized: "discover.filter.all", bundle: .module),
                    isSelected: store.state.selectedGenre == nil,
                ) {
                    store.send(.genreSelected(nil))
                }
                ForEach(store.state.availableGenres, id: \.self) { genre in
                    FilterChip(title: genre.displayName, isSelected: store.state.selectedGenre == genre) {
                        store.send(.genreSelected(genre))
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("discover.filter.label", bundle: .module))
        .accessibilityIdentifier(AccessibilityID.genreFilter)
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
        let cardWidth = DesignSystem.Size.Poster.card(posterWidth, at: dynamicTypeSize)
        return ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                ForEach(movies) { movie in
                    movieButton(movie, caption: movie.genreName, posterWidth: cardWidth)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .scrollIndicators(.hidden)
    }

    func movieButton(_ movie: Movie, caption: String?, posterWidth: CGFloat) -> some View {
        Button {
            onSelectMovie(movie)
        } label: {
            MovieCard(
                title: movie.title,
                caption: caption,
                posterURL: movie.posterURL,
                width: posterWidth,
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text("accessibility.opensDetails", bundle: .module))
        .accessibilityIdentifier(AccessibilityID.movieCard)
    }
}

// MARK: - Helpers
private extension DiscoverView {
    var rowCardWidth: CGFloat {
        DesignSystem.Size.Poster.card(DesignSystem.Size.Poster.row, at: dynamicTypeSize)
    }

    var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: rowCardWidth), spacing: DesignSystem.Spacing.md)]
    }
}

// MARK: - Actions
private extension DiscoverView {
    /// Bridges the system pull-to-refresh control to the store: dispatch the
    /// refresh intent, then await the resulting fetch so the spinner stays up
    /// until fresh content arrives.
    func refresh() async {
        store.send(.refresh)
        await store.settle()
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
