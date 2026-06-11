import CinematicDesign
import SwiftUI

/// Mirrors the loaded detail layout: poster, title block, summary lines.
struct MovieDetailSkeleton: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                poster
                titleBlock
                summaryLines
            }
            .padding(DesignSystem.Spacing.md)
        }
        .scrollDisabled(true)
        .accessibilityElement()
        .accessibilityLabel(Text("accessibility.loading", bundle: .module))
    }
}

// MARK: - Sub-views
private extension MovieDetailSkeleton {
    var poster: some View {
        SkeletonView()
            .frame(
                width: DesignSystem.Size.Poster.featured,
                height: DesignSystem.Size.Poster.featured * PosterImage.heightToWidthRatio,
            )
    }

    var titleBlock: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            SkeletonView(cornerRadius: DesignSystem.CornerRadius.sm)
                .frame(width: DesignSystem.Size.Poster.featured, height: DesignSystem.Size.Skeleton.header)
            SkeletonView(cornerRadius: DesignSystem.CornerRadius.sm)
                .frame(width: DesignSystem.Size.Poster.row, height: DesignSystem.Size.Skeleton.line)
        }
    }

    var summaryLines: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(0..<4, id: \.self) { _ in
                SkeletonView(cornerRadius: DesignSystem.CornerRadius.sm)
                    .frame(height: DesignSystem.Size.Skeleton.line)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
