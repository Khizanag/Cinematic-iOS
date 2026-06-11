@testable import MVIKit
import Testing

struct EffectTests {
    @Test("none carries no operations")
    func noneIsEmpty() {
        #expect(Effect<Int>.none.operations.isEmpty)
    }

    @Test("merge flattens operations in order, dropping empty effects")
    func mergeFlattens() {
        let merged = Effect<Int>.merge(
            .none,
            .cancel("first"),
            .run { _ in },
            .none,
        )
        #expect(merged.operations.count == 2)
    }

    @Test("Effect ids compare by their raw value")
    func effectIDEquality() {
        #expect(EffectID("search") == "search")
        #expect(EffectID("search") != EffectID("load"))
    }
}
