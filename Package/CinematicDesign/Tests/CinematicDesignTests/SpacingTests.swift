import CinematicDesign
import Testing

struct SpacingTests {
    @Test("Spacing scale is strictly ascending")
    func spacingScaleAscending() {
        let scale = [
            DesignSystem.Spacing.xxs,
            DesignSystem.Spacing.xs,
            DesignSystem.Spacing.sm,
            DesignSystem.Spacing.md,
            DesignSystem.Spacing.lg,
            DesignSystem.Spacing.xl,
            DesignSystem.Spacing.xxl,
        ]
        #expect(scale == scale.sorted())
        #expect(Set(scale).count == scale.count)
    }
}
