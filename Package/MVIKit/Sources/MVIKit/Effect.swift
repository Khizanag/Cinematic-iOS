/// Identifies one logical stream of effect work, for cancellation.
///
/// Starting an effect with the id of one already in flight cancels the old
/// run first ("switch latest") — which is exactly the behavior a debounced
/// search or a pull-to-refresh wants.
nonisolated public struct EffectID: Hashable, Sendable, ExpressibleByStringLiteral {
    private let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

/// A value describing the side effects of one `reduce` call.
///
/// Reducers *return* effects; the ``Store`` *executes* them. Keeping effects
/// as data is what keeps reducers pure.
nonisolated public struct Effect<Intent: Sendable>: Sendable {
    enum Operation: Sendable {
        case run(id: EffectID?, work: @Sendable (Send<Intent>) async -> Void)
        case cancel(EffectID)
    }

    let operations: [Operation]

    private init(operations: [Operation]) {
        self.operations = operations
    }
}

// MARK: - Constructors
extension Effect {
    /// No side effect. The intent only changed state.
    public static var none: Effect {
        Effect(operations: [])
    }

    /// Runs asynchronous work that can feed intents back into the store.
    ///
    /// Pass an `id` to make the work cancellable: a later `.run` with the same
    /// id replaces (cancels) this one, and `.cancel(id)` stops it outright.
    /// Work should check `Task.isCancelled` after suspension points.
    public static func run(
        id: EffectID? = nil,
        _ work: @escaping @Sendable (_ send: Send<Intent>) async -> Void,
    ) -> Effect {
        Effect(operations: [.run(id: id, work: work)])
    }

    /// Cancels the in-flight effect started with `id`, if any.
    public static func cancel(_ id: EffectID) -> Effect {
        Effect(operations: [.cancel(id)])
    }

    /// Combines several effects into one. Operations run in order.
    public static func merge(_ effects: [Effect]) -> Effect {
        Effect(operations: effects.flatMap(\.operations))
    }

    public static func merge(_ effects: Effect...) -> Effect {
        merge(effects)
    }
}
