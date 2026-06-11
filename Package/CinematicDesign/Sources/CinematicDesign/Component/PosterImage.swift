import SwiftUI

// MARK: - PosterImage
/// A movie poster at the standard 2:3 aspect: skeleton while loading, quiet
/// film-strip placeholder when there is no artwork.
///
/// Decorative by contract — always pair it with visible text, so it is
/// hidden from VoiceOver here rather than at every call site.
public struct PosterImage: View {
    /// Height divided by width — the 2:3 poster sheet.
    public static let heightToWidthRatio: CGFloat = 1.5

    private let url: URL?
    private let width: CGFloat

    public init(url: URL?, width: CGFloat) {
        self.url = url
        self.width = width
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                placeholder
            case .empty:
                loadingState
            @unknown default:
                placeholder
            }
        }
        .frame(width: width, height: width * Self.heightToWidthRatio)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.md))
        .accessibilityHidden(true)
    }
}

// MARK: - Sub-views
private extension PosterImage {
    var placeholder: some View {
        ZStack {
            DesignSystem.Color.separator
            Image(systemName: "film")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    @ViewBuilder
    var loadingState: some View {
        if url == nil {
            placeholder
        } else {
            SkeletonView()
        }
    }
}
