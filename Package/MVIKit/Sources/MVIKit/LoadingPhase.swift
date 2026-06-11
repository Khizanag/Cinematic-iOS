/// Exhaustive state for an asynchronously loaded value.
///
/// Feature states embed a `LoadingPhase` per asynchronous load instead of
/// scattering `isLoading` / `error` booleans, so views `switch` over a single
/// value and every state has exactly one rendering.
///
/// `Failure` is the *domain* error type of the load, which keeps the whole
/// phase `Equatable` and lets reducers be asserted value-for-value in tests.
/// Use `Never` for loads that cannot fail.
nonisolated public enum LoadingPhase<Value, Failure: Error> {
    case idle
    case loading
    case loaded(Value)
    case failed(Failure)
}

// MARK: - Accessors
extension LoadingPhase {
    /// The loaded value, when present.
    public var value: Value? {
        if case let .loaded(value) = self { value } else { nil }
    }

    public var isLoading: Bool {
        if case .loading = self { true } else { false }
    }
}

// MARK: - Equatable
extension LoadingPhase: Equatable where Value: Equatable, Failure: Equatable {}

// MARK: - Sendable
extension LoadingPhase: Sendable where Value: Sendable, Failure: Sendable {}
