import CinematicPresentation
import SwiftUI

/// Maps a `Cover` to its full-screen content. Like sheets, covers get their
/// own `NavigationStack` and the shared close item, and dismiss through the
/// `dismiss` environment, so no coordinator plumbing crosses the
/// presentation boundary.
struct CoverFactory: View {
    @Environment(\.dismiss) private var dismiss

    let cover: Cover

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    CloseToolbarItem { dismiss() }
                }
        }
    }
}

// MARK: - Content
private extension CoverFactory {
    @ViewBuilder
    var content: some View {
        switch cover {
        case let .trailer(url):
            TrailerPlayerView(url: url)
                // Video is dark in both appearances; so is its chrome.
                .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
