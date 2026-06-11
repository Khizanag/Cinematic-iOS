/// Feeds intents from inside an effect back into the store, on the main actor.
///
/// `Send` is the only channel from asynchronous work to state: effects never
/// touch state directly, they describe what happened as an intent and let the
/// reducer apply it.
nonisolated public struct Send<Intent: Sendable>: Sendable {
    private let handler: @MainActor @Sendable (Intent) -> Void

    init(handler: @escaping @MainActor @Sendable (Intent) -> Void) {
        self.handler = handler
    }

    /// Sends an intent unless the effect was cancelled in the meantime.
    public func callAsFunction(_ intent: Intent) async {
        guard !Task.isCancelled else { return }
        await handler(intent)
    }
}
