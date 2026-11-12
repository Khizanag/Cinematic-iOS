import SwiftUI

// MARK: - FilterChip
/// A capsule toggle for one option of a single-choice filter. Pure: selection
/// in, action out — the caller owns what the filter means.
public struct FilterChip: View {
    private let title: String
    private let isSelected: Bool
    private let action: () -> Void

    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Font.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, DesignSystem.Spacing.md)
                .frame(minHeight: DesignSystem.Size.Button.minimumTapTarget)
                .background(background, in: .capsule)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Helpers
private extension FilterChip {
    var background: Color {
        isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground
    }
}

#Preview {
    HStack {
        FilterChip(title: "All", isSelected: true) {}
        FilterChip(title: "Drama", isSelected: false) {}
    }
    .padding()
    .background(DesignSystem.Color.background)
}
