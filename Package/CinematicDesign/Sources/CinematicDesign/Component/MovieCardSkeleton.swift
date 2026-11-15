import SwiftUI

// MARK: - MovieCardSkeleton
/// A shimmering stand-in for `MovieCard`, the same size at every text size,
/// so loaded cards replace it without anything below them moving.
public struct MovieCardSkeleton: View {
    private let width: CGFloat

    public init(width: CGFloat) {
        self.width = width
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            SkeletonView()
                .frame(width: width, height: width * PosterImage.heightToWidthRatio)
            // A space, not an empty string: empty text reserves no lines.
            MovieCardText(title: " ", caption: " ")
                .hidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .topLeading) { lines }
        }
        .frame(width: width, alignment: .leading)
        .accessibilityHidden(true)
    }
}

// MARK: - Sub-views
private extension MovieCardSkeleton {
    var lines: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SkeletonView(cornerRadius: DesignSystem.CornerRadius.sm)
                .frame(height: DesignSystem.Size.Skeleton.line)
            SkeletonView(cornerRadius: DesignSystem.CornerRadius.sm)
                .frame(height: DesignSystem.Size.Skeleton.line)
                .padding(.trailing, DesignSystem.Spacing.xl)
        }
        .padding(.top, DesignSystem.Spacing.xxs)
    }
}
