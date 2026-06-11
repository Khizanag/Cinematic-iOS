import CinematicDesign
import CinematicDomain
import MVIKit
import SwiftUI

/// Catalog search with native `searchable`, debounced through the reducer.
public struct SearchView: View {
    private let onSelectMovie: (Movie) -> Void

    @State private var store: Store<SearchReducer>

    public init(
        searchMovies: SearchMoviesUseCase,
        onSelectMovie: @escaping (Movie) -> Void,
    ) {
        _store = State(initialValue: Store(
            initialState: SearchReducer.State(),
            reducer: SearchReducer(searchMovies: searchMovies),
        ))
        self.onSelectMovie = onSelectMovie
    }

    public var body: some View {
        content
            .background(DesignSystem.Color.background)
            .navigationTitle(Text("search.title", bundle: .module))
            .searchable(text: query, prompt: Text("search.prompt", bundle: .module))
    }
}

// MARK: - Sub-views
private extension SearchView {
    @ViewBuilder
    var content: some View {
        switch store.state.results {
        case .idle:
            idleState
        case .loading:
            SearchSkeleton()
        case let .loaded(movies) where movies.isEmpty:
            ContentUnavailableView.search(text: store.state.query)
        case let .loaded(movies):
            resultsGrid(movies)
        case let .failed(error):
            ErrorStateView(error: error) { store.send(.searchNow) }
        }
    }

    var idleState: some View {
        ContentUnavailableView {
            Label(
                String(localized: "search.idle.title", bundle: .module),
                systemImage: "movieclapper",
            )
        } description: {
            Text("search.idle.description", bundle: .module)
        }
    }

    func resultsGrid(_ movies: [Movie]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: DesignSystem.Spacing.md) {
                ForEach(movies) { movie in
                    movieButton(movie)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityIdentifier(AccessibilityID.searchResults)
    }

    func movieButton(_ movie: Movie) -> some View {
        Button {
            onSelectMovie(movie)
        } label: {
            MovieCard(
                title: movie.title,
                caption: movie.directorName,
                posterURL: movie.posterURL,
                width: DesignSystem.Size.Poster.row,
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Helpers
private extension SearchView {
    var query: Binding<String> {
        store.binding(\.query) { .queryChanged($0) }
    }

    var columns: [GridItem] {
        [
            GridItem(
                .adaptive(minimum: DesignSystem.Size.Poster.row),
                spacing: DesignSystem.Spacing.md,
            ),
        ]
    }
}

#Preview {
    NavigationStack {
        SearchView(
            searchMovies: SearchMoviesUseCase(repository: PreviewMovieCatalogRepository()),
            onSelectMovie: { _ in },
        )
    }
}
