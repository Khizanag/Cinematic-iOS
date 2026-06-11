import CinematicDomain
import SwiftUI

/// The one error rendering every screen shares: native
/// `ContentUnavailableView` with a translated message and a retry action.
struct ErrorStateView: View {
    let error: MovieError
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(
                String(localized: "error.title", bundle: .module),
                systemImage: error.symbolName,
            )
        } description: {
            Text(error.userMessage)
        } actions: {
            Button(String(localized: "action.retry", bundle: .module), action: retry)
                .buttonStyle(.borderedProminent)
        }
    }
}
