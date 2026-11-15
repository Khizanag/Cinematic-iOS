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
        .accessibilityElement()
        .accessibilityLabel(Text("accessibility.loading", bundle: .module))
    }
}

// MARK: - Sub-views
private extension DiscoverSkeleton {
    func section(posterWidth: CGFloat) -> some View {
        let cardWidth = DesignSystem.Size.Poster.card(posterWidth, at: dynamicTypeSize)
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            header
                .padding(.horizontal, DesignSystem.Spacing.md)
            // Scrolled like a loaded row: a row wider than the screen, laid out
            // in the vertical scroll view, would be centered and start off-screen.
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    ForEach(0..<4, id: \.self) { _ in
                        MovieCardSkeleton(width: cardWidth)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
            .scrollDisabled(true)
            .scrollIndicators(.hidden)
        }
    }

    /// A hidden header under the placeholder holds the loaded header's height
    /// at every text size.
    var header: some View {
        SectionHeader(title: " ", systemImage: Self.headerSymbol)
            .hidden()
            .overlay(alignment: .leading) {
                SkeletonView(cornerRadius: DesignSystem.CornerRadius.sm)
                    .frame(width: DesignSystem.Size.Poster.row, height: DesignSystem.Size.Skeleton.header)
            }
    }
}

// MARK: - Helpers
private extension DiscoverSkeleton {
    static let headerSymbol = "star"
}
