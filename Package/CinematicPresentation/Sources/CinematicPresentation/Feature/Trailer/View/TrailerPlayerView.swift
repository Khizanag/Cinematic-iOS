import AVKit
import CinematicDesign
import Combine
import SwiftUI

/// Full-screen trailer playback.
///
/// Deliberately bare: no `NavigationStack`, no toolbar — a glass bar would
/// live-sample the video layer for its blur. The close control sits top
/// trailing so the player's own fullscreen toggle (top leading) stays
/// reachable, and a loading overlay bridges the gap between presentation and
/// the first rendered frame.
public struct TrailerPlayerView: View {
    private enum PlaybackPhase {
        case loading
        case playing
        case failed
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @State private var player: AVPlayer
    @State private var playerItem: AVPlayerItem
    @State private var phase: PlaybackPhase = .loading

    public init(url: URL) {
        let item = AVPlayerItem(url: url)
        _playerItem = State(initialValue: item)
        _player = State(initialValue: AVPlayer(playerItem: item))
    }

    public var body: some View {
        VideoPlayer(player: player)
            .ignoresSafeArea()
            .onAppear(perform: startPlayback)
            .onDisappear { player.pause() }
            .onReceive(player.publisher(for: \.timeControlStatus)) { updatePhase(timeControlStatus: $0) }
            .onReceive(playerItem.publisher(for: \.status)) { updatePhase(itemStatus: $0) }
            .overlay { statusOverlay }
            .overlay(alignment: .topTrailing) { closeButton }
            .animation(DesignSystem.Motion.quick, value: phase)
    }
}

// MARK: - Sub-views
private extension TrailerPlayerView {
    @ViewBuilder
    var statusOverlay: some View {
        switch phase {
        case .loading:
            loadingIndicator
        case .failed:
            failureNotice
        case .playing:
            EmptyView()
        }
    }

    var loadingIndicator: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ProgressView()
                .tint(DesignSystem.Color.onMedia)
            Text("trailer.loading", bundle: .module)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.onMedia)
        }
        .accessibilityElement(children: .combine)
        .allowsHitTesting(false)
    }

    var failureNotice: some View {
        Label {
            Text("trailer.failed", bundle: .module)
        } icon: {
            Image(systemName: "play.slash")
        }
        .font(DesignSystem.Font.subheadline)
        .foregroundStyle(DesignSystem.Color.onMedia)
        .padding(DesignSystem.Spacing.md)
    }

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

// MARK: - Actions
private extension TrailerPlayerView {
    func startPlayback() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        player.play()
    }

    func updatePhase(timeControlStatus: AVPlayer.TimeControlStatus) {
        if timeControlStatus == .playing {
            phase = .playing
        }
    }

    func updatePhase(itemStatus: AVPlayerItem.Status) {
        if itemStatus == .failed {
            phase = .failed
        }
    }
}
