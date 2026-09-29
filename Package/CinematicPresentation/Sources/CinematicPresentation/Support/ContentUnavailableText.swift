import CinematicDesign
import SwiftUI

// MARK: - ContentUnavailableView text
extension Text {
    /// A `ContentUnavailableView` title that wraps at accessibility text sizes;
    /// the view otherwise truncates its title to one line.
    func unavailableTitle() -> some View {
        fixedSize(horizontal: false, vertical: true)
    }

    /// A `ContentUnavailableView` description in the design system's secondary
    /// text color, which meets contrast where the view's default gray does not.
    func unavailableDescription() -> some View {
        foregroundStyle(DesignSystem.Color.textSecondary)
    }
}
