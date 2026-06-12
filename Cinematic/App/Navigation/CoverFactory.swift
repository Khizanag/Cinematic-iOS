import CinematicPresentation
import SwiftUI

/// Maps a `Cover` to its full-screen content. Covers own their dismissal
/// through the `dismiss` environment, so no coordinator plumbing is needed
/// across the presentation boundary.
struct CoverFactory: View {
    let cover: Cover

    var body: some View {
        switch cover {
        case let .trailer(url):
            TrailerPlayerView(url: url)
        }
    }
}
