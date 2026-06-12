import SwiftUI

// MARK: - Transparent system chrome
extension View {
    /// Bars stay pure floating glass: no scroll-edge fade painting the
    /// background color over content, no tab-bar backdrop. Content remains
    /// fully visible behind the navigation and tab bars.
    func transparentSystemChrome() -> some View {
        scrollEdgeEffectHidden(for: .all)
            .toolbarBackgroundVisibility(.hidden, for: .tabBar)
    }
}
