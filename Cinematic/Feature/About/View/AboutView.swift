import CinematicDesign
import SwiftUI

/// What this app is and why it exists, with a pointer to the repository.
struct AboutView: View {
    @Environment(TabCoordinator.self) private var coordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                headline
                bodyText
                repositoryLink
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background)
        .navigationTitle(Text("about.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CloseToolbarItem { coordinator.dismiss() }
        }
    }
}

// MARK: - Sub-views
private extension AboutView {
    var headline: some View {
        Text("about.headline")
            .font(DesignSystem.Font.title2)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    var bodyText: some View {
        Text("about.body")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    @ViewBuilder
    var repositoryLink: some View {
        if let url = URL(string: "https://github.com/Khizanag/Cinematic-iOS") {
            Link(destination: url) {
                Label {
                    Text("about.repository")
                } icon: {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                }
            }
            .font(DesignSystem.Font.headline)
        }
    }
}
