import MVIKit
import Testing

private struct CounterReducer: Reducer {
    struct State: Equatable {
        var count = 0
        var isWorking = false
    }

    enum Intent: Sendable {
        case increment
        case incrementTwiceViaMergedEffects
        case delayedIncrement
        case delayedIncrementLanded
        case cancelDelayedIncrement
        case setCount(Int)
    }

    func reduce(_ state: inout State, _ intent: Intent) -> Effect<Intent> {
        switch intent {
        case .increment:
            state.count += 1
            return .none

        case .incrementTwiceViaMergedEffects:
            return .merge(
                .run { send in await send(.increment) },
                .run { send in await send(.increment) },
            )

        case .delayedIncrement:
            state.isWorking = true
            return .run(id: "delayed") { send in
                try? await Task.sleep(for: .milliseconds(40))
                guard !Task.isCancelled else { return }
                await send(.delayedIncrementLanded)
            }

        case .delayedIncrementLanded:
            state.isWorking = false
            state.count += 1
            return .none

        case .cancelDelayedIncrement:
            state.isWorking = false
            return .cancel("delayed")

        case let .setCount(count):
            state.count = count
            return .none
        }
    }
}

@MainActor
struct StoreTests {
    @Test("Synchronous intents mutate state immediately")
    func synchronousIntentMutatesState() {
        let store = makeStore()
        store.send(.increment)
        #expect(store.state.count == 1)
        #expect(!store.hasPendingEffects)
    }

    @Test("Effects deliver follow-up intents back through the reducer")
    func effectDeliversFollowUpIntent() async {
        let store = makeStore()
        store.send(.delayedIncrement)
        #expect(store.state.isWorking)
        await store.settle()
        #expect(store.state == CounterReducer.State(count: 1, isWorking: false))
    }

    @Test("Restarting an identified effect cancels the previous run")
    func identifiedEffectSwitchesToLatest() async {
        let store = makeStore()
        store.send(.delayedIncrement)
        store.send(.delayedIncrement)
        await store.settle()
        #expect(store.state.count == 1)
    }

    @Test("cancel(id:) stops an in-flight effect")
    func explicitCancelStopsEffect() async {
        let store = makeStore()
        store.send(.delayedIncrement)
        store.send(.cancelDelayedIncrement)
        await store.settle()
        #expect(store.state.count == 0)
        #expect(!store.hasPendingEffects)
    }

    @Test("Merged effects all run")
    func mergedEffectsAllRun() async {
        let store = makeStore()
        store.send(.incrementTwiceViaMergedEffects)
        await store.settle()
        #expect(store.state.count == 2)
    }

    @Test("Bindings read state and write through intents")
    func bindingRoundTrip() {
        let store = makeStore()
        let binding = store.binding(\.count, send: CounterReducer.Intent.setCount)
        #expect(binding.wrappedValue == 0)
        binding.wrappedValue = 5
        #expect(store.state.count == 5)
    }
}

// MARK: - Helpers
private extension StoreTests {
    func makeStore() -> Store<CounterReducer> {
        Store(initialState: CounterReducer.State(), reducer: CounterReducer())
    }
}
