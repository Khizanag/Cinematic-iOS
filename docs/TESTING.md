# Testing

What each layer's tests prove, how the doubles work, and the commands that run everything. All unit tests use Swift Testing; XCTest appears only in the XCUITest target, where it has no replacement.

## The matrix

| Suite | Runs on | Command | Proves |
|---|---|---|---|
| `MVIKitTests` | macOS host | `cd Package/MVIKit && swift test` | The loop itself: effects feed back, identified effects switch-latest, `cancel` stops work, bindings round-trip |
| `CinematicDomainTests` | macOS host | `cd Package/CinematicDomain && swift test` | Business rules: genre ordering and degradation, query hygiene, snapshot-then-changes streaming |
| `CinematicDataTests` | macOS host | `cd Package/CinematicData && swift test` | Wire truth: DTO decoding against captured payloads, error mapping per status and `URLError`, local search ranking, cache fallback, persistence round-trips |
| `CinematicDesignTests` | iOS simulator | `xcodebuild test -scheme CinematicDesign -destination 'platform=iOS Simulator,name=iPhone 17'` | Token invariants |
| `CinematicPresentationTests` | iOS simulator | `xcodebuild test -scheme CinematicPresentation -destination 'platform=iOS Simulator,name=iPhone 17'` | Every reducer's state machine, pure and through the live loop |
| `CinematicTests` + `CinematicUITests` | iOS simulator | `xcodebuild test -project Cinematic.xcodeproj -scheme Cinematic -destination 'platform=iOS Simulator,name=iPhone 17'` | Composition wiring, deep-link routing, and three black-box user flows |

The split is platform-driven: packages that never import UIKit or SwiftUI declare macOS support and test in seconds with `swift test`; UI packages test on a simulator.

## Doubles, by layer

**Domain and presentation** test against hand-rolled stubs, not mocks. Catalog stubs are value types configured with `Result`s at construction — no shared state, no expectations DSL. The favorites stub is a real actor with the same broadcast semantics the production repository honors, because the *contract* (subscribe-before-snapshot, emit-on-every-change) is exactly what the tests must exercise.

**Data** tests stub the network underneath a real `URLSession` via `URLProtocol`, so decoding, status handling, and error mapping run the production path. The stub is `Mutex`-guarded because Swift Testing runs in parallel; suites that share fixed URLs are marked `.serialized`.

**Previews, presentation tests, and UI tests share one fixture set** — `PreviewSupport` in `CinematicPresentation`. The app's `-uiTestMode` launch argument swaps the composition root onto those same doubles, which is why the UI tests are deterministic and run offline.

## Testing the loop

Request-shaped flows settle:

```swift
store.send(.task)
await store.settle()
#expect(store.state.catalog.value?.featured == PreviewCatalog.movies)
```

`settle()` waits for every in-flight effect, including effects spawned by the intents those effects send.

Stream-fed stores never settle — their observation effect is deliberately immortal — so those tests drive the stub and poll with a bounded helper:

```swift
store.send(.task)
await favorites.toggle(movie)
await waitUntil { store.state.isFavorite }
```

`waitUntil` yields between checks and records an issue on timeout. The pattern to remember: settle for pipelines, poll for subscriptions, and end a stub's streams (`finishAllStreams`) if you do need a subscription store to settle.

## Reading coverage

Every `xcodebuild test` invocation above accepts `-resultBundlePath TestResults.xcresult`; inspect with:

```bash
xcrun xccov view --report --only-targets TestResults.xcresult
```

The logic targets are the ones to watch — reducers, use cases, mappers, and repositories are the design's claims, and the suites above hold them at high coverage (the presentation package sits near 90% including view code; the pure layers higher). Chasing percentage inside SwiftUI `body` code buys little; the UI tests cover those paths end to end instead.
