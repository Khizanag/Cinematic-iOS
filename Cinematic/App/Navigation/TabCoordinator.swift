import SwiftUI

/// Owns the navigation state for a single tab: its push stack plus the active
/// sheet and cover. Views call `push` / `present` / `presentCover` — never
/// `NavigationLink`.
@MainActor
@Observable
final class TabCoordinator {
    let tab: AppTab
    var path: [Screen] = []
    var activeSheet: Sheet?
    var activeCover: Cover?

    init(tab: AppTab) {
        self.tab = tab
    }

    func push(_ screen: Screen) {
        path.append(screen)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func present(_ sheet: Sheet) {
        activeSheet = sheet
    }

    func presentCover(_ cover: Cover) {
        activeCover = cover
    }

    func dismiss() {
        if activeCover != nil {
            activeCover = nil
        } else {
            activeSheet = nil
        }
    }
}
