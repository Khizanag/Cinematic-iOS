import AVKit
import CinematicDesign
import Combine
import SwiftUI

/// Full-screen trailer playback.
///
/// Dismissal is the presenter's job: the composition root hosts this view in
/// a `NavigationStack` with the app's shared close item. The video stays
/// inside the safe area, below that bar, so the player's own controls are
/// never covered and the bar's glass samples the black backdrop rather than
/// moving video. A loading overlay bridges the gap between presentation and
/// the first rendered frame.
public struct TrailerPlayerView: View {
    private enum PlaybackPhase {
        case loading
        case playing
        case failed
    }

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
            .background(DesignSystem.Color.mediaBackground.ignoresSafeArea())
            .onAppear(perform: startPlayback)
            .onDisappear { player.pause() }
            .onReceive(player.publisher(for: \.timeControlStatus)) { updatePhase(timeControlStatus: $0) }
            .onReceive(playerItem.publisher(for: \.status)) { updatePhase(itemStatus: $0) }
            .overlay { statusOverlay }
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
