/// Streams the favorites list: the current value immediately, then every
/// subsequent change. One long-lived subscription keeps every screen that
/// shows favorite state consistent without manual refresh choreography.
public struct ObserveFavoritesUseCase: Sendable {
    private let repository: any FavoritesRepository

    public init(repository: any FavoritesRepository) {
        self.repository = repository
    }

    public func execute() -> AsyncStream<[Movie]> {
        let repository = repository
        return AsyncStream { continuation in
            let task = Task {
                // Subscribe before reading the snapshot so a toggle racing the
                // first read is buffered by the stream, not lost.
                let changes = await repository.changes()
                continuation.yield(await repository.favorites())
                for await favorites in changes {
                    continuation.yield(favorites)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
