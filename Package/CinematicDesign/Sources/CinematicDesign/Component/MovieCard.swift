import SwiftUI

// MARK: - MovieCard
/// Poster, title, and an optional caption — the unit of every carousel and
/// grid. Reads as one element to VoiceOver.
public struct MovieCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let title: String
    private let caption: String?
    private let posterURL: URL?
    private let width: CGFloat

    public init(title: String, caption: String? = nil, posterURL: URL?, width: CGFloat) {
        self.title = title
        self.caption = caption
        self.posterURL = posterURL
        self.width = width
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            PosterImage(url: posterURL, width: width)
            text
        }
        .frame(width: width, alignment: .leading)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Sub-views
private extension MovieCard {
    var text: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(titleLineLimit, reservesSpace: true)
                .multilineTextAlignment(.leading)
            Text(caption ?? "")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(captionLineLimit, reservesSpace: true)
        }
    }
}

// MARK: - Helpers
private extension MovieCard {
    // Every card in a row reserves the same text height, even without a
    // caption. A lazy carousel sizes its row from the first card it lays out,
    // so a taller card after it would be squeezed and its text cut short.
    // Accessibility sizes reserve more lines, since cards keep a fixed width.
    var titleLineLimit: Int {
        dynamicTypeSize.isAccessibilitySize ? 3 : 2
    }

    var captionLineLimit: Int {
        dynamicTypeSize.isAccessibilitySize ? 2 : 1
    }
}
