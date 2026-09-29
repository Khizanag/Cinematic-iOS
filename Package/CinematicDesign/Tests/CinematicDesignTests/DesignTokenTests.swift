import CinematicDesign
import SwiftUI
import Testing

struct DesignTokenTests {
    @Test("Corner radii scale up monotonically")
    func cornerRadiiAscend() {
        let scale = [
            DesignSystem.CornerRadius.sm,
            DesignSystem.CornerRadius.md,
            DesignSystem.CornerRadius.lg,
            DesignSystem.CornerRadius.xl,
        ]
        #expect(scale == scale.sorted())
    }

    @Test("Poster widths scale up monotonically")
    func posterWidthsAscend() {
        let scale = [
            DesignSystem.Size.Poster.thumbnail,
            DesignSystem.Size.Poster.row,
            DesignSystem.Size.Poster.featured,
            DesignSystem.Size.Poster.accessibilityCard,
        ]
        #expect(scale == scale.sorted())
    }

    @Test("Cards widen only at accessibility text sizes", arguments: [
        (DynamicTypeSize.large, false),
        (.xxxLarge, false),
        (.accessibility1, true),
        (.accessibility5, true),
    ])
    func cardWidthFollowsTextSize(size: DynamicTypeSize, widens: Bool) {
        let expected = widens ? DesignSystem.Size.Poster.accessibilityCard : DesignSystem.Size.Poster.row
        #expect(DesignSystem.Size.Poster.card(DesignSystem.Size.Poster.row, at: size) == expected)
    }

    @Test("Posters keep the 2:3 sheet aspect")
    func posterAspectRatio() {
        #expect(PosterImage.heightToWidthRatio == 1.5)
    }
}
