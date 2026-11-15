import CinematicDesign
import SwiftUI
import Testing
import UIKit

struct MovieCardSkeletonTests {
    @Test("The skeleton takes the loaded card's exact size", arguments: Self.textSizes)
    func skeletonMatchesCard(size: DynamicTypeSize) {
        let width = DesignSystem.Size.Poster.card(DesignSystem.Size.Poster.row, at: size)
        let card = MovieCard(title: "Title", caption: "Caption", posterURL: nil, width: width)
        let skeleton = MovieCardSkeleton(width: width)

        #expect(fittingSize(of: skeleton, at: size) == fittingSize(of: card, at: size))
    }
}

// MARK: - Helpers
private extension MovieCardSkeletonTests {
    nonisolated static let textSizes: [DynamicTypeSize] = [.large, .xxxLarge, .accessibility1, .accessibility5]

    func fittingSize(of view: some View, at size: DynamicTypeSize) -> CGSize {
        UIHostingController(rootView: view.environment(\.dynamicTypeSize, size))
            .sizeThatFits(in: UIView.layoutFittingExpandedSize)
    }
}
