# Adding a feature

The recipe, inward-out. Work in this order and every step compiles against the previous one. The favorites feature is the running example — open its files next to each step.

## 0. Decide the seam

Name the screen's state, the events that can happen to it, and the domain question it asks. If the domain question already has a use case, skip to step 3.

## 1. Domain: the contract

Add what the feature needs to `CinematicDomain` — an entity field, a repository method, or a use case.

```swift
public struct ObserveFavoritesUseCase: Sendable {
    private let repository: any FavoritesRepository

    public init(repository: any FavoritesRepository) {
        self.repository = repository
    }

    public func execute() -> AsyncStream<[Movie]> { … }
}
```

Rules that keep the layer clean: entities stay `Codable`-free, methods throw `MovieError` via typed throws, and any business rule (ordering, thresholds, tolerance for partial failure) lands here — not in the reducer, not in the repository.

Test it in `CinematicDomainTests` with the in-memory stubs.

## 2. Data: the implementation

Implement the new contract in `CinematicData`: endpoint case, DTO fields, mapper lines, repository method. Keep the API's quirks inside — above this layer they don't exist.

Test against captured payloads and the `URLProtocol` stub. If the call should survive offline, the cache decorator needs a matching method with a cache key.

## 3. Presentation: the state machine

Create the feature folder:

```text
Package/CinematicPresentation/Sources/CinematicPresentation/Feature/Favorites/
  FavoritesReducer.swift
  View/
    FavoritesView.swift
    FavoritesSkeleton.swift
```

Write the reducer first — state, intents, transitions, effects:

```swift
struct FavoritesReducer: Reducer {
    struct State: Equatable {
        var favorites: LoadingPhase<[Movie], Never> = .idle
    }

    enum Intent: Sendable {
        case task
        case favoritesChanged([Movie])
        case removeTapped(Movie)
    }
    // reduce + private effect helpers
}
```

Then the view: `@State private var store`, a small `body`, subviews in a `private extension`, a `switch` over the phase with a skeleton that mirrors the loaded layout, `ContentUnavailableView` for empty, and navigation expressed as injected closures (`onSelectMovie`), never coordinator calls.

Strings go in the package's `Localizable.xcstrings` (`Text("favorites.title", bundle: .module)`); a `#Preview` runs on the `PreviewSupport` doubles.

Write reducer tests in `CinematicPresentationTests`: pure transitions first, then a store-level test through the real use case and a stub repository.

## 4. App: wiring

Three small edits in the app target:

1. `Dependencies.swift` — expose the new use case, built in `init` from the repositories.
2. `Screen.swift` / `Sheet.swift` / `Cover.swift` — add a case if the feature is a destination.
3. The matching factory (or `ContentView` for a new tab) — construct the view, injecting use cases from `\.dependencies` and translating its events into coordinator calls.

Nothing else changes. That locality is the payoff of factories.

## 5. Prove it

```bash
swiftlint lint --strict
cd Package/CinematicPresentation && xcodebuild test -scheme CinematicPresentation -destination 'platform=iOS Simulator,name=iPhone 17'
xcodebuild test -project Cinematic.xcodeproj -scheme Cinematic -destination 'platform=iOS Simulator,name=iPhone 17'
```

Checklist before calling it done:

- [ ] Reducer transitions covered by tests, including the failure path
- [ ] Skeleton mirrors the loaded layout (no jump on content swap)
- [ ] Empty and error states render `ContentUnavailableView`
- [ ] Every interactive element has an accessibility label; looping animation guarded by Reduce Motion
- [ ] No string literals in feature code — String Catalog keys only
- [ ] No `DesignSystem` bypass — tokens for every color, font, spacing, and size
- [ ] `swiftlint --strict` is silent and the build has zero warnings
