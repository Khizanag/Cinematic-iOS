import AppIntents

/// The Siri phrases and Shortcuts tiles that work with no setup.
///
/// Phrases are literals because App Intents reads them at build time; their
/// translations live in `AppShortcuts.xcstrings`.
struct CinematicShortcuts: AppShortcutsProvider {
    static let shortcutTileColor: ShortcutTileColor = .purple

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TopMoviesIntent(),
            phrases: [
                "What's trending in \(.applicationName)",
                "Show the top movies in \(.applicationName)",
                "\(.applicationName) top movies",
            ],
            shortTitle: "intent.topMovies.shortTitle",
            systemImageName: "chart.line.uptrend.xyaxis",
        )
        AppShortcut(
            intent: ShowFavoritesIntent(),
            phrases: [
                "Show my favorites in \(.applicationName)",
                "Open my \(.applicationName) favorites",
            ],
            shortTitle: "intent.showFavorites.shortTitle",
            systemImageName: "heart",
        )
        AppShortcut(
            intent: OpenMovieIntent(),
            phrases: [
                "Open \(\.$target) in \(.applicationName)",
                "Show \(\.$target) in \(.applicationName)",
            ],
            shortTitle: "intent.openMovie.shortTitle",
            systemImageName: "film",
        )
    }
}
