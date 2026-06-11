import CinematicDesign
import SwiftUI

/// Mirrors the loaded discover layout, so content replaces placeholders
/// without the page jumping.
struct DiscoverSkeleton: View {
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
        .accessibilityElement()
        .accessibilityLabel(Text("accessibility.loading", bundle: .module))
    }
}

// MARK: - Sub-views
private extension DiscoverSkeleton {
    func section(posterWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SkeletonView(cornerRadius: DesignSystem.CornerRadius.sm)
                .frame(
                    width: DesignSystem.Size.Poster.row,
                    height: DesignSystem.Size.Skeleton.header,
                )
            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonView()
                        .frame(
                            width: posterWidth,
                            height: posterWidth * PosterImage.aspectRatio,
                        )
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}
