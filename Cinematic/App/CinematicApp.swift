import AppIntents
import CinematicDesign
import SwiftUI

@main
struct CinematicApp: App {
    private let dependencies: AppDependencies

    @State private var coordinator: AppCoordinator

    init() {
        let dependencies = AppDependencies.current()
        let coordinator = AppCoordinator()
        #if DEBUG
        // `-deepLink cinematic://movie/<id>` routes at launch — lets the
        // screenshot harness and CLI runs skip the system open-URL prompt.
        if let raw = UserDefaults.standard.string(forKey: "deepLink"), let url = URL(string: raw) {
            coordinator.handle(url)
        }
        #endif
        // Intents resolve these with `@Dependency`, so a Shortcut sees the
        // same favorites and navigation as the screens.
        AppDependencyManager.shared.add(dependency: dependencies)
        AppDependencyManager.shared.add(dependency: coordinator)
        self.dependencies = dependencies
        _coordinator = State(initialValue: coordinator)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(coordinator)
                .environment(\.dependencies, dependencies)
                .tint(DesignSystem.Color.accent)
                .calmForUITests()
                .onOpenURL { coordinator.handle($0) }
                .task { CinematicShortcuts.updateAppShortcutParameters() }
        }
    }
}
