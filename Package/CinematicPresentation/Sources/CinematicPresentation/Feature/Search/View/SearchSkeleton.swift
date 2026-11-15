import CinematicDesign
import SwiftUI

/// Mirrors the results grid while a search is in flight.
struct SearchSkeleton: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: DesignSystem.Spacing.md) {
                ForEach(0..<6, id: \.self) { _ in
                    MovieCardSkeleton(width: cardWidth)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .scrollDisabled(true)
        .accessibilityElement()
        .accessibilityLabel(Text("accessibility.loading", bundle: .module))
    }
}

// MARK: - Helpers
private extension SearchSkeleton {
    var cardWidth: CGFloat {
        DesignSystem.Size.Poster.card(DesignSystem.Size.Poster.row, at: dynamicTypeSize)
    }

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: cardWidth), spacing: DesignSystem.Spacing.md)]
    }
}
