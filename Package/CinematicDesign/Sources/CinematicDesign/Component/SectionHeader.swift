import SwiftUI

// MARK: - SectionHeader
/// A section title with an optional trailing action.
///
/// Takes resolved `String`s, not `LocalizedStringKey`s: keys resolve against
/// the *defining* module's bundle, so cross-package components let callers
/// localize in their own catalog first.
public struct SectionHeader: View {
    private let title: String
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(DesignSystem.Font.title3)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            trailingAction
        }
    }
}

// MARK: - Sub-views
private extension SectionHeader {
    @ViewBuilder
    var trailingAction: some View {
        if let actionTitle, let action {
            Button(actionTitle, action: action)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}
