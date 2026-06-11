import CinematicDesign
import SwiftUI

@main
struct CinematicApp: App {
    private let dependencies = AppDependencies.current()

    @State private var coordinator: AppCoordinator

    init() {
        let coordinator = AppCoordinator()
        #if DEBUG
        // `-deepLink cinematic://movie/<id>` routes at launch — lets the
        // screenshot harness and CLI runs skip the system open-URL prompt.
        if let raw = UserDefaults.standard.string(forKey: "deepLink"), let url = URL(string: raw) {
            coordinator.handle(url)
        }
        #endif
        _coordinator = State(initialValue: coordinator)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(coordinator)
                .environment(\.dependencies, dependencies)
                .tint(DesignSystem.Color.accent)
                .onOpenURL { coordinator.handle($0) }
        }
    }
}
