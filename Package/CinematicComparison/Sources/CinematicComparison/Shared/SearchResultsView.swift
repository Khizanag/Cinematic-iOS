import CinematicDomain
import MVIKit
import SwiftUI

/// Renders one search state. Every variant draws through this view, so the
/// only difference between them is how the state is produced.
struct SearchResultsView: View {
    let query: String
    let results: LoadingPhase<[Movie], MovieError>

    var body: some View {
        switch results {
        case .idle:
            idleState
        case .loading:
            skeleton
        case let .loaded(movies) where movies.isEmpty:
            ContentUnavailableView.search(text: query)
        case let .loaded(movies):
            List(movies) { movie in
                Text(movie.title)
            }
        case .failed:
            failedState
        }
    }
}

// MARK: - Sub-views
private extension SearchResultsView {
    var idleState: some View {
        ContentUnavailableView {
            Label(
                String(localized: "comparison.idle.title", bundle: .module),
                systemImage: "movieclapper",
            )
        } description: {
            Text("comparison.idle.description", bundle: .module)
        }
    }

    var failedState: some View {
        ContentUnavailableView {
            Label(
                String(localized: "comparison.error.title", bundle: .module),
                systemImage: "exclamationmark.triangle",
            )
        } description: {
            Text("comparison.error.description", bundle: .module)
        }
    }

    /// Placeholder rows shaped like the loaded list, read by VoiceOver as one
    /// loading element.
    var skeleton: some View {
        List(0..<8, id: \.self) { _ in
            Text(verbatim: "Placeholder movie title")
        }
        .redacted(reason: .placeholder)
        .scrollDisabled(true)
        .accessibilityElement()
        .accessibilityLabel(Text("comparison.loading", bundle: .module))
    }
}
