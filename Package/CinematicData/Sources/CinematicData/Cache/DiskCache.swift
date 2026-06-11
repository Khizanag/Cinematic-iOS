import Foundation
import OSLog

/// A tiny JSON-file store under `Caches/` — one key, one file.
///
/// Eviction is the system's: iOS may purge `Caches/` under pressure, which is
/// exactly the right durability for offline-fallback data. Write failures are
/// logged, never thrown — a cache that can't write is a cache, not an error.
actor DiskCache {
    private let directory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let logger = Logger(subsystem: "com.khizanag.cinematic", category: "DiskCache")

    init(directory: URL) {
        self.directory = directory
    }

    init(name: String) {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.init(directory: base.appending(path: name, directoryHint: .isDirectory))
    }

    func write(_ value: some Encodable, forKey key: String) {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try encoder.encode(value).write(to: fileURL(forKey: key), options: .atomic)
        } catch {
            logger.error("Cache write failed for '\(key)': \(error)")
        }
    }

    func read<Value: Decodable>(forKey key: String) -> Value? {
        guard let data = try? Data(contentsOf: fileURL(forKey: key)) else { return nil }
        do {
            return try decoder.decode(Value.self, from: data)
        } catch {
            logger.error("Cache read failed for '\(key)': \(error)")
            return nil
        }
    }
}

// MARK: - Helpers
private extension DiskCache {
    func fileURL(forKey key: String) -> URL {
        let safeKey = key.replacing(/[^A-Za-z0-9._-]/, with: "_")
        return directory.appending(path: "\(safeKey).json")
    }
}
