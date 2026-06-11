import CinematicDesign
import SwiftUI

@main
struct CinematicApp: App {
    @State private var coordinator = AppCoordinator()

    private let dependencies = AppDependencies.current()

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
