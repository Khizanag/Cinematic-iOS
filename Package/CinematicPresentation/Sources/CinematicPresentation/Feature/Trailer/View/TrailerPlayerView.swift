import AVKit
import CinematicDesign
import SwiftUI

/// Full-screen trailer playback.
///
/// Deliberately bare: no `NavigationStack`, no toolbar. A glass bar would
/// live-sample the video layer for its blur — heavy, and a known source of
/// AsyncRenderer crashes — so dismissal is a plain overlay button instead,
/// and the view owns it through the standard `dismiss` environment.
public struct TrailerPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @State private var player: AVPlayer

    public init(url: URL) {
        _player = State(initialValue: AVPlayer(url: url))
    }

    public var body: some View {
        VideoPlayer(player: player)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) { closeButton }
            .onAppear {
                try? AVAudioSession.sharedInstance().setCategory(.playback)
                player.play()
            }
            .onDisappear { player.pause() }
    }
}

// MARK: - Sub-views
private extension TrailerPlayerView {
    var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(DesignSystem.Spacing.sm)
                .background(closeButtonBackground, in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .padding(DesignSystem.Spacing.md)
        .accessibilityLabel(Text("general.close", bundle: .module))
    }

    var closeButtonBackground: AnyShapeStyle {
        reduceTransparency
            ? AnyShapeStyle(DesignSystem.Color.cardBackground)
            : AnyShapeStyle(.ultraThinMaterial)
    }
}
