import CinematicDesign
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
        ]
        #expect(scale == scale.sorted())
    }

    @Test("Posters keep the 2:3 sheet aspect")
    func posterAspectRatio() {
        #expect(PosterImage.heightToWidthRatio == 1.5)
    }
}
