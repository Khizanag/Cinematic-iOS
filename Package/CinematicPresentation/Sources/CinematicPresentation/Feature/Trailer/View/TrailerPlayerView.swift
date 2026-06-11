import AVKit
import SwiftUI

/// Full-screen trailer playback. AVKit owns the transport controls; the view
/// only starts playback on appear and stops it on dismissal.
public struct TrailerPlayerView: View {
    @State private var player: AVPlayer

    public init(url: URL) {
        _player = State(initialValue: AVPlayer(url: url))
    }

    public var body: some View {
        VideoPlayer(player: player)
            .ignoresSafeArea()
            .onAppear {
                try? AVAudioSession.sharedInstance().setCategory(.playback)
                player.play()
            }
            .onDisappear { player.pause() }
    }
}
