import CinematicDesign
import SwiftUI

/// Mirrors the loaded discover layout, so content replaces placeholders
/// without the page jumping.
struct DiscoverSkeleton: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                section(posterWidth: DesignSystem.Size.Poster.featured)
                section(posterWidth: DesignSystem.Size.Poster.row)
                section(posterWidth: DesignSystem.Size.Poster.row)
            }
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .scrollDisabled(true)
        .safeAreaBar(edge: .top) { filterBar }
        .accessibilityElement()
        .accessibilityLabel(Text("accessibility.loading", bundle: .module))
    }
}

// MARK: - Sub-views
private extension DiscoverSkeleton {
    var filterBar: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(0..<4, id: \.self) { _ in
                SkeletonView(cornerRadius: DesignSystem.Size.Button.minimumTapTarget / 2)
                    .frame(
                        width: DesignSystem.Size.Skeleton.chip,
                        height: DesignSystem.Size.Button.minimumTapTarget,
                    )
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }

    func section(posterWidth: CGFloat) -> some View {
        let cardWidth = DesignSystem.Size.Poster.card(posterWidth, at: dynamicTypeSize)
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SkeletonView(cornerRadius: DesignSystem.CornerRadius.sm)
                .frame(
                    width: DesignSystem.Size.Poster.row,
                    height: DesignSystem.Size.Skeleton.header,
                )
            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonView()
                        .frame(
                            width: cardWidth,
                            height: cardWidth * PosterImage.heightToWidthRatio,
                        )
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}
