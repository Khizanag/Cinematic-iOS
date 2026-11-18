import AppIntents
import CinematicDomain

/// "What's trending in Cinematic?" Answers with the top of the chart without
/// opening the app, and returns the movies for the next Shortcuts action.
struct TopMoviesIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.topMovies.title"
    static let description = IntentDescription("intent.topMovies.description")
    static let spokenLimit = 3
    static let resultLimit = 10

    @Parameter(title: "intent.topMovies.genre")
    var genre: GenreAppEnum?

    @Dependency private var dependencies: AppDependencies

    func perform() async throws -> some IntentResult & ReturnsValue<[MovieEntity]> & ProvidesDialog {
        let movies = try await dependencies.fetchTopMovies.execute(genre: genre?.genre, limit: Self.resultLimit)
        return .result(value: movies.map(MovieEntity.init), dialog: Self.dialog(for: movies))
    }

    static func dialog(for movies: [Movie]) -> IntentDialog {
        guard !movies.isEmpty else {
            return IntentDialog("intent.topMovies.empty")
        }
        let titles = movies.prefix(spokenLimit).map(\.title).formatted(.list(type: .and))
        return IntentDialog("intent.topMovies.dialog \(titles)")
    }
}
