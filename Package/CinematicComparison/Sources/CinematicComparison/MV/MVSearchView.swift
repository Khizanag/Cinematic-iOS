import CinematicDomain
import SwiftUI

/// MV: the view owns the query and drives the model directly.
///
/// `.task(id: query)` is the whole concurrency story. SwiftUI cancels the
/// running task whenever the query changes, which gives debounce and
/// switch-latest for free — and puts both where only a UI test can reach them.
struct MVSearchView: View {
    let debounce: Duration

    @State private var query = ""
    @State private var search: MovieSearch

    init(searchMovies: SearchMoviesUseCase, debounce: Duration = .milliseconds(250)) {
        self.debounce = debounce
        _search = State(initialValue: MovieSearch(searchMovies: searchMovies))
    }

    var body: some View {
        SearchResultsView(query: query, results: search.results)
            .searchable(text: $query, prompt: Text("comparison.search.prompt", bundle: .module))
            .task(id: query) {
                if MovieSearch.isSearchable(query) {
                    try? await Task.sleep(for: debounce)
                    guard !Task.isCancelled else { return }
                }
                await search.search(for: query)
            }
    }
}

#Preview {
    NavigationStack {
        MVSearchView(searchMovies: .preview)
    }
}
