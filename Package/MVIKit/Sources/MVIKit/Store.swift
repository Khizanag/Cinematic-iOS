import SwiftUI

/// Drives one feature: holds its state, accepts intents, runs the reducer,
/// and executes the returned effects.
///
/// The store is the unidirectional loop of MVI:
///
/// ```text
/// View ──send(intent)──▶ Store ──reduce──▶ State ──▶ View
///                          │                  ▲
///                          └──Effect──async───┘ (as new intents)
/// ```
///
/// `state` is read-only from the outside — the only way to change it is to
/// send an intent.
@MainActor
@Observable
public final class Store<R: Reducer> {
    public private(set) var state: R.State

    @ObservationIgnored private let reducer: R
    @ObservationIgnored private var runningEffects: [EffectID: RunningEffect] = [:]
    @ObservationIgnored private var nextToken = 0
    @ObservationIgnored private var nextAnonymousID = 0

    public init(initialState: R.State, reducer: R) {
        state = initialState
        self.reducer = reducer
    }

    deinit {
        for effect in runningEffects.values {
            effect.task.cancel()
        }
    }

    public func send(_ intent: R.Intent) {
        let effect = reducer.reduce(&state, intent)
        handle(effect)
    }
}

// MARK: - SwiftUI bindings
extension Store {
    /// A two-way binding that reads from state and writes by sending an
    /// intent — for APIs that require a `Binding`, like `searchable` or
    /// `TextField`. Writes still flow through the reducer, so the
    /// unidirectional loop stays intact.
    public func binding<Value>(
        _ keyPath: KeyPath<R.State, Value>,
        send intent: @escaping (Value) -> R.Intent,
    ) -> Binding<Value> {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { self.send(intent($0)) },
        )
    }
}

// MARK: - Test support
extension Store {
    public var hasPendingEffects: Bool {
        !runningEffects.isEmpty
    }

    /// Suspends until every in-flight effect — including effects started by
    /// the intents those effects send — has finished.
    ///
    /// Intended for tests. Long-lived subscription effects never finish on
    /// their own; end their source (or cancel them) before settling.
    public func settle() async {
        while let effect = runningEffects.values.first {
            await effect.task.value
        }
    }
}

// MARK: - Effect execution
private extension Store {
    struct RunningEffect {
        let token: Int
        let task: Task<Void, Never>
    }

    func handle(_ effect: Effect<R.Intent>) {
        for operation in effect.operations {
            switch operation {
            case let .run(id, work):
                run(id: id, work)
            case let .cancel(id):
                runningEffects[id]?.task.cancel()
            }
        }
    }

    func run(id: EffectID?, _ work: @escaping @Sendable (Send<R.Intent>) async -> Void) {
        let key = id ?? makeAnonymousID()
        runningEffects[key]?.task.cancel()

        let token = nextToken
        nextToken += 1

        let send = Send<R.Intent> { [weak self] intent in
            self?.send(intent)
        }
        let task = Task { [weak self] in
            await work(send)
            self?.finishEffect(for: key, token: token)
        }
        runningEffects[key] = RunningEffect(token: token, task: task)
    }

    /// Removes the bookkeeping entry — unless a newer run already replaced it.
    func finishEffect(for key: EffectID, token: Int) {
        guard runningEffects[key]?.token == token else { return }
        runningEffects[key] = nil
    }

    func makeAnonymousID() -> EffectID {
        nextAnonymousID += 1
        return EffectID("mvikit.anonymous.\(nextAnonymousID)")
    }
}
