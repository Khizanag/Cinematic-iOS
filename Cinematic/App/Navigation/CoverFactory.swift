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
                    .toolbar { closeButton }
            }
        }
    }
}

// MARK: - Toolbar
private extension CoverFactory {
    var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                coordinator.dismiss()
            } label: {
                Image(systemName: "xmark")
            }
            .accessibilityLabel(Text("general.close"))
        }
    }
}
