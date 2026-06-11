import Foundation

/// Apple artwork URLs end in a rendition component like `113x170bb.png`.
/// Swapping that last component asks the CDN for a different size of the same
/// asset — the documented-by-practice way to get high-resolution posters from
/// feeds that only ship thumbnails.
enum ArtworkURL {
    static func resized(_ url: URL?, to size: Int) -> URL? {
        guard let url else { return nil }
        guard url.lastPathComponent.contains(/^\d+x\d+/) else { return url }
        return url
            .deletingLastPathComponent()
            .appending(path: "\(size)x\(size)bb.jpg")
    }
}
