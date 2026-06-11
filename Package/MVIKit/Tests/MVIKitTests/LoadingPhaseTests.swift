import MVIKit
import Testing

struct LoadingPhaseTests {
    private enum TestFailure: Error, Equatable {
        case broken
    }

    @Test("value is exposed only in the loaded phase")
    func valueAccessor() {
        #expect(LoadingPhase<Int, Never>.loaded(7).value == 7)
        #expect(LoadingPhase<Int, TestFailure>.idle.value == nil)
        #expect(LoadingPhase<Int, TestFailure>.loading.value == nil)
        #expect(LoadingPhase<Int, TestFailure>.failed(.broken).value == nil)
    }

    @Test("isLoading is true only while loading")
    func isLoading() {
        #expect(LoadingPhase<Int, Never>.loading.isLoading)
        #expect(!LoadingPhase<Int, Never>.idle.isLoading)
    }

    @Test("phases with equatable payloads compare by value")
    func equality() {
        #expect(LoadingPhase<Int, TestFailure>.loaded(1) == .loaded(1))
        #expect(LoadingPhase<Int, TestFailure>.loaded(1) != .loaded(2))
        #expect(LoadingPhase<Int, TestFailure>.failed(.broken) == .failed(.broken))
    }
}
