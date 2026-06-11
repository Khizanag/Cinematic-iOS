import CinematicDomain

/// Push destinations within a tab's `NavigationStack`.
/// Recipe to add one: add a `case` here, handle it in `ScreenFactory`.
/// No other file changes.
enum Screen: Hashable {
    case movieDetail(id: Movie.ID)
}
