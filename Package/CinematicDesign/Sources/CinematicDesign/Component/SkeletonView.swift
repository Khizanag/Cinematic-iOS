import SwiftUI

// MARK: - SkeletonView
/// A shimmering placeholder block. Build screen-specific skeletons from these
/// — never show a bare full-screen `ProgressView`. The shimmer is suppressed
/// under Reduce Motion.
///
/// The pulse is a `phaseAnimator`, not `repeatForever`: skeletons live inside
/// `AsyncImage` placeholders and lazy containers, and a `repeatForever`
/// animation torn down mid-render is a known AsyncRenderer crash.
public struct SkeletonView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = DesignSystem.CornerRadius.md) {
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        if reduceMotion {
            shape.opacity(0.65)
        } else {
            shape.phaseAnimator([0.85, 0.45]) { view, opacity in
                view.opacity(opacity)
            } animation: { _ in
                .easeInOut(duration: 0.9)
            }
        }
    }
}

// MARK: - Sub-views
private extension SkeletonView {
    var shape: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(DesignSystem.Color.separator)
            .accessibilityHidden(true)
    }
}
