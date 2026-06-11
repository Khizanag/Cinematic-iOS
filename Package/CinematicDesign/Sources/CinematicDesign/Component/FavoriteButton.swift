import SwiftUI

// MARK: - FavoriteButton
/// Heart toggle with a bounce on change. Pure: state in, action out — the
/// caller owns what "favorite" means.
public struct FavoriteButton: View {
    private let isFavorite: Bool
    private let label: String
    private let action: () -> Void

    public init(isFavorite: Bool, label: String, action: @escaping () -> Void) {
        self.isFavorite = isFavorite
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .symbolEffect(.bounce, value: isFavorite)
                .foregroundStyle(isFavorite ? DesignSystem.Color.danger : DesignSystem.Color.accent)
        }
        .sensoryFeedback(.selection, trigger: isFavorite)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isFavorite ? .isSelected : [])
    }
}
