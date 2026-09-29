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
                .lineLimit(titleLineLimit, reservesSpace: !dynamicTypeSize.isAccessibilitySize)
                .multilineTextAlignment(.leading)
            if let caption {
                Text(caption)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(captionLineLimit)
            }
        }
    }
}

// MARK: - Helpers
private extension MovieCard {
    // Cards keep a fixed width, so accessibility sizes wrap onto more lines
    // instead of truncating. Only the regular sizes reserve the two-line
    // height that keeps a carousel's cards aligned.
    var titleLineLimit: Int {
        dynamicTypeSize.isAccessibilitySize ? 5 : 2
    }

    var captionLineLimit: Int {
        dynamicTypeSize.isAccessibilitySize ? 3 : 1
    }
}
