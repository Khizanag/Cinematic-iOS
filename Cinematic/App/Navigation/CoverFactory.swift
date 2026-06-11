import CinematicPresentation
import SwiftUI

/// Maps a `Cover` to its full-screen content.
struct CoverFactory: View {
    @Environment(TabCoordinator.self) private var coordinator

    let cover: Cover

    var body: some View {
        switch cover {
        case let .trailer(url):
            NavigationStack {
                TrailerPlayerView(url: url)
                    .toolbar {
                        CloseToolbarItem { coordinator.dismiss() }
                    }
            }
        }
    }
}
