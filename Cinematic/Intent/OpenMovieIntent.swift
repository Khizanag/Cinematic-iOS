import AppIntents
import CinematicDomain

/// Opens a movie's detail screen, through the same route as a deep link.
struct OpenMovieIntent: OpenIntent {
    static let title: LocalizedStringResource = "intent.openMovie.title"
    static let description = IntentDescription("intent.openMovie.description")

    @Parameter(title: "intent.openMovie.movie")
    var target: MovieEntity

    @Dependency private var coordinator: AppCoordinator

    @MainActor
    func perform() async throws -> some IntentResult {
        coordinator.showMovie(Movie.ID(target.id))
        return .result()
    }
}
