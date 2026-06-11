import CinematicDesign
import SwiftUI

/// Mirrors the results grid while a search is in flight.
struct SearchSkeleton: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
                ForEach(0..<6, id: \.self) { _ in
                    cell
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .scrollDisabled(true)
        .accessibilityElement()
        .accessibilityLabel(Text("accessibility.loading", bundle: .module))
    }
}

// MARK: - Sub-views
private extension SearchSkeleton {
    var columns: [GridItem] {
        [
            GridItem(
                .adaptive(minimum: DesignSystem.Size.Poster.row),
                spacing: DesignSystem.Spacing.md,
            ),
        ]
    }

    var cell: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            SkeletonView()
                .aspectRatio(1 / PosterImage.heightToWidthRatio, contentMode: .fit)
            SkeletonView(cornerRadius: DesignSystem.CornerRadius.sm)
                .frame(height: DesignSystem.Size.Skeleton.line)
        }
    }
}
