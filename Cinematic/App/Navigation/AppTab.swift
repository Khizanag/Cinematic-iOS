import SwiftUI

/// The app's top-level tabs. Each tab owns an isolated navigation stack so
/// switching tabs never disturbs another tab's state.
enum AppTab: Int, CaseIterable, Identifiable {
    case discover
    case search
    case favorites

    var id: Int { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .discover: "tab.discover"
        case .search: "tab.search"
        case .favorites: "tab.favorites"
        }
    }

    var systemImage: String {
        switch self {
        case .discover: "film.stack"
        case .search: "magnifyingglass"
        case .favorites: "heart"
        }
    }

    /// `.search` opts the tab into the system search appearance on iOS 26.
    var role: TabRole? {
        self == .search ? .search : nil
    }
}
