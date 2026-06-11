import Testing

struct CompositionTests {
    @Test("Test host launches with the app target linked")
    func hostIsWired() {
        #expect(Bundle.main.bundleIdentifier == "com.khizanag.cinematic")
    }
}
