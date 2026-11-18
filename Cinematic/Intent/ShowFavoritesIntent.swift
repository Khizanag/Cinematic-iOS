import AppIntents

/// Opens the app on the Favorites tab.
struct ShowFavoritesIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.showFavorites.title"
    static let description = IntentDescription("intent.showFavorites.description")
    static let supportedModes: IntentModes = .foreground

    @Dependency private var coordinator: AppCoordinator

    @MainActor
    func perform() async throws -> some IntentResult {
        coordinator.show(.favorites)
        return .result()
    }
}
