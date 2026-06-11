import CinematicDesign
import SwiftUI

/// Mirrors the favorites list rows during the initial load.
struct FavoritesSkeleton: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ForEach(0..<5, id: \.self) { _ in
                row
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .accessibilityElement()
        .accessibilityLabel(Text("accessibility.loading", bundle: .module))
    }
}

// MARK: - Sub-views
private extension FavoritesSkeleton {
    var row: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SkeletonView()
                .frame(
                    width: DesignSystem.Size.Poster.thumbnail,
                    height: DesignSystem.Size.Poster.thumbnail * PosterImage.aspectRatio,
                )
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                SkeletonView(cornerRadius: DesignSystem.CornerRadius.sm)
                    .frame(height: DesignSystem.Size.Skeleton.line)
                SkeletonView(cornerRadius: DesignSystem.CornerRadius.sm)
                    .frame(width: DesignSystem.Size.Poster.row, height: DesignSystem.Size.Skeleton.line)
            }
        }
    }
}
