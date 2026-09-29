import SwiftUI

// MARK: - Dynamic Type
extension DesignSystem.Size.Poster {
    /// The narrowest a movie card gets at accessibility text sizes: wide
    /// enough that a title wraps between words instead of inside them.
    public static let accessibilityCard: CGFloat = 280

    /// The width a movie card takes at `dynamicTypeSize`: `width` at regular
    /// sizes, and at least `accessibilityCard` at accessibility sizes.
    public static func card(_ width: CGFloat, at dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? max(width, accessibilityCard) : width
    }
}
