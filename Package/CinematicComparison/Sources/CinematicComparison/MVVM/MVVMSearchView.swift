import CinematicDomain
import SwiftUI

/// MVVM: the view binds to the view model and holds no logic of its own.
struct MVVMSearchView: View {
    @State private var viewModel: SearchViewModel

    init(searchMovies: SearchMoviesUseCase, debounce: Duration = .milliseconds(250)) {
        _viewModel = State(initialValue: SearchViewModel(searchMovies: searchMovies, debounce: debounce))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        SearchResultsView(query: viewModel.query, results: viewModel.results)
            .searchable(text: $viewModel.query, prompt: Text("comparison.search.prompt", bundle: .module))
    }
}

#Preview {
    NavigationStack {
        MVVMSearchView(searchMovies: .preview)
    }
}
