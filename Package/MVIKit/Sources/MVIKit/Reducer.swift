/// A pure description of how one feature's state evolves.
///
/// `reduce(_:_:)` is the only place state changes. It applies an intent to the
/// state synchronously and returns an ``Effect`` describing any asynchronous
/// work. The reducer never performs side effects itself — that separation is
/// what makes every state transition assertable value-for-value in tests.
///
/// Reducers are plain values. Dependencies (use cases) are stored properties,
/// injected through the initializer by the composition root.
@MainActor
public protocol Reducer<State, Intent> {
    /// The complete, value-typed state of the feature.
    associatedtype State

    /// Everything that can happen to the feature — user actions and effect
    /// results alike. One closed set, so the state machine is exhaustive.
    associatedtype Intent: Sendable

    func reduce(_ state: inout State, _ intent: Intent) -> Effect<Intent>
}
