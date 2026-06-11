import SwiftUI

// MARK: - SkeletonView
/// A shimmering placeholder block. Build screen-specific skeletons from these
/// — never show a bare full-screen `ProgressView`. The shimmer is suppressed
/// under Reduce Motion.
public struct SkeletonView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    private let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = DesignSystem.CornerRadius.md) {
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(DesignSystem.Color.separator)
            .opacity(isAnimating ? 0.45 : 0.85)
            .animation(shimmer, value: isAnimating)
            .onAppear { isAnimating = true }
            .accessibilityHidden(true)
    }
}

// MARK: - Helpers
private extension SkeletonView {
    var shimmer: Animation {
        reduceMotion
            ? .default
            : .easeInOut(duration: 0.9).repeatForever(autoreverses: true)
    }
}
