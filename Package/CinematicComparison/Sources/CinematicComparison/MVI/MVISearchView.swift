import CinematicDomain
import MVIKit
import SwiftUI

/// MVI: the view reads state and sends intents. It never mutates anything.
struct MVISearchView: View {
    @State private var store: Store<SearchReducer>

    init(searchMovies: SearchMoviesUseCase, debounce: Duration = .milliseconds(250)) {
        _store = State(initialValue: Store(
            initialState: SearchReducer.State(),
            reducer: SearchReducer(searchMovies: searchMovies, debounce: debounce),
        ))
    }

    var body: some View {
        SearchResultsView(query: store.state.query, results: store.state.results)
            .searchable(text: query, prompt: Text("comparison.search.prompt", bundle: .module))
    }
}

// MARK: - Helpers
private extension MVISearchView {
    var query: Binding<String> {
        store.binding(\.query) { .queryChanged($0) }
    }
}

#Preview {
    NavigationStack {
        MVISearchView(searchMovies: .preview)
    }
}
