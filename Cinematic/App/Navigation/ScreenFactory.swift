import CinematicPresentation
import SwiftUI

/// Maps a `Screen` to its destination view, injecting use cases from the
/// composition root and translating feature events into coordinator calls.
/// Feature views never know navigation exists.
struct ScreenFactory: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(TabCoordinator.self) private var coordinator

    let screen: Screen

    var body: some View {
        switch screen {
        case let .movieDetail(id):
            MovieDetailView(
                movieID: id,
                fetchMovieDetails: dependencies.fetchMovieDetails,
                toggleFavorite: dependencies.toggleFavorite,
                observeFavorites: dependencies.observeFavorites,
                onPlayTrailer: { coordinator.presentCover(.trailer(url: $0)) },
            )
        }
    }
}
