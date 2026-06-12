import SwiftUI

/// Wraps a tab's `NavigationStack` and binds its sheet + cover. This is the
/// one and only place in the app allowed to declare `.navigationDestination`,
/// `.sheet`, and `.fullScreenCover` for coordinated routing. Child views push
/// and present through the `TabCoordinator` in the environment.
struct CoordinatedNavigationStack<Root: View>: View {
    @Bindable var coordinator: TabCoordinator
    @ViewBuilder var root: () -> Root

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            root()
                .transparentSystemChrome()
                .navigationDestination(for: Screen.self) { screen in
                    ScreenFactory(screen: screen)
                }
        }
        .sheet(item: $coordinator.activeSheet) { sheet in
            SheetFactory(sheet: sheet)
        }
        .fullScreenCover(item: $coordinator.activeCover) { cover in
            CoverFactory(cover: cover)
        }
        .environment(coordinator)
    }
}
