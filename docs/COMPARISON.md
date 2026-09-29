# MV vs MVVM vs MVI, one feature three ways

The README's comparison table makes claims. This page tests them. Catalog search is built three times over the same `SearchMoviesUseCase`, in [`Package/CinematicComparison`](https://github.com/Khizanag/Cinematic-iOS/tree/main/Package/CinematicComparison), and one behavioural test suite runs against each version. The code is short enough to read side by side, and the differences are about where each guarantee lives, not about how many lines it takes.

## The feature

Search looks simple and isn't. Every version must keep four promises:

1. **Keystrokes collapse.** Typing "voyage" letter by letter sends one request, for "voyage".
2. **A short query resets.** Below two characters the screen returns to idle, and a pending search is cancelled.
3. **Stale responses are dropped.** If the answer for "du" arrives after the answer for "dune", the screen still shows "dune".
4. **Failures are typed.** A failed search shows `MovieError`, not `any Error`.

Promise 3 is the one that separates the architectures. A response for a query the user already replaced must never reach the screen, even when the network layer ignores cancellation and answers late.

## The three versions at a glance

| | MV | MVVM | MVI |
|---|---|---|---|
| Files | `MovieSearch` + `MVSearchView` | `SearchViewModel` + `MVVMSearchView` | `SearchReducer` + `MVISearchView` |
| Code lines | 51 | 63 | 77, plus the shared MVIKit |
| Where the query lives | View `@State` | View model | Reducer state |
| Who debounces | SwiftUI's `.task(id:)` | A hand-written `Task` | An `Effect` with an `EffectID` |
| Who drops stale results | `guard !Task.isCancelled` in the model | `guard !Task.isCancelled` in the view model | The store: `Send` drops intents from cancelled effects |
| How a test waits | Awaits the model call | A hand-written `settle()` | `Store.settle()`, shared by every feature |

Code lines exclude blank lines, comments and previews. All three render through the same `SearchResultsView`, so the views differ only in wiring.

## MV

The model performs one search and holds the result. It knows nothing about typing or which request is current:

```swift
func search(for query: String) async {
    guard Self.isSearchable(query) else {
        results = .idle
        return
    }
    results = .loading
    do throws(MovieError) {
        let movies = try await searchMovies.execute(query: query)
        // A cancelled call belongs to a query the user already replaced.
        guard !Task.isCancelled else { return }
        results = .loaded(movies)
    } catch {
        guard !Task.isCancelled else { return }
        results = .failed(error)
    }
}
```

The view does the rest with one modifier. SwiftUI cancels the running task whenever `query` changes, which is both the debounce and the switch-latest. A short query skips the wait, so the screen resets on the keystroke:

```swift
.task(id: query) {
    if MovieSearch.isSearchable(query) {
        try? await Task.sleep(for: debounce)
        guard !Task.isCancelled else { return }
    }
    await search.search(for: query)
}
```

`MovieSearch` is not a view model under another name. It doesn't own the query, the debounce or the task; the view does. It is the one testable unit MV keeps. The purist form holds `results` in the view's `@State` and calls the use case straight from `.task(id:)`, which leaves nothing to unit-test at all.

**What you get:** the least code, and concurrency handled by the framework.
**What you give up:** promises 1 and 2 live inside SwiftUI. A unit test can't type into a view, so only a UI test can check them. The stale guard is still yours to write, because SwiftUI cancels the task but can't stop a late answer from being assigned.

## MVVM

The view model owns the query and the task in flight. Every write to `query` cancels the previous task before starting the next:

```swift
func queryChanged() {
    searchTask?.cancel()
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.count >= SearchMoviesUseCase.minimumQueryLength else {
        results = .idle
        searchTask = nil
        return
    }
    searchTask = Task { [weak self, debounce] in
        try? await Task.sleep(for: debounce)
        guard !Task.isCancelled else { return }
        await self?.search(for: trimmed)
    }
}
```

`search(for:)` carries the same `guard !Task.isCancelled` as MV. To let tests observe the result, the view model also exposes a `settle()` that awaits `searchTask`.

**What you get:** every promise is unit-testable, and the view holds no logic.
**What you give up:** cancellation is bookkeeping you write by hand: the stored task, the cancel before each start, the guard after each await, and the test seam. Every view model with async work repeats it, and forgetting any one line is a silent bug.

## MVI

The reducer describes work instead of doing it. Debounce and request share one `EffectID`, so starting either cancels whatever was in flight:

```swift
return .run(id: Self.searchEffect) { send in
    try? await Task.sleep(for: debounce)
    await send(.searchNow)
}
```

There is no stale guard in the reducer at all. `Send` drops any intent from a cancelled effect, so a late answer never becomes an intent, and the reducer never sees it.

Where that guard runs matters. MVIKit 1.0.0 checked for cancellation before hopping to the main actor, so a cancel landing between the check and the hop, such as a keystroke while an answer was being delivered, still let one stale intent through. [1.0.1](https://github.com/Khizanag/MVIKit/releases/tag/1.0.1) moved the check onto the main actor, next to where cancellation happens. The fix was one function in one place, and every feature in the app picked it up with a version bump. MVVM and MV get this right without thinking about it, because their guards already run on the main actor, directly before the assignment.

**What you get:** every promise is unit-testable. The cancellation rules are written once, in MVIKit, and every feature inherits them. `Store.settle()` is the same test seam everywhere.
**What you give up:** the most structure: an intent enum, a reducer, and effects as values. On a screen with no concurrency, that's ceremony.

## What the tests show

[`SearchBehaviorTests`](https://github.com/Khizanag/Cinematic-iOS/blob/main/Package/CinematicComparison/Tests/CinematicComparisonTests/SearchBehaviorTests.swift) runs the same four test bodies against MVVM and MVI. [`MovieSearchTests`](https://github.com/Khizanag/Cinematic-iOS/blob/main/Package/CinematicComparison/Tests/CinematicComparisonTests/MovieSearchTests.swift) checks what MV's model owns, with the test playing SwiftUI's part by cancelling the stale call itself.

| Promise | MV | MVVM | MVI |
|---|---|---|---|
| Keystrokes collapse | SwiftUI (UI test only) | Unit test | Unit test |
| A short query resets | Model: unit test; cancelling: SwiftUI | Unit test | Unit test |
| Stale responses are dropped | Unit test | Unit test | Unit test |
| Failures are typed | Unit test | Unit test | Unit test |

The stale-response test is only meaningful if the late answer really arrives last. The scripted repository holds the "du" answer back and ignores cancellation, as many network layers do, so it lands after "dune" has already been shown.

Each test was checked by breaking the code it guards:

| Change | Test that fails |
|---|---|
| Delete MVVM's stale guard | Stale responses are dropped (MVVM) |
| Revert MVIKit's `Send` to its 1.0.0 check | `SendTests` in [MVIKit](https://github.com/Khizanag/MVIKit/blob/main/Tests/MVIKitTests/SendTests.swift) |
| Delete MV's stale guard | A cancelled call never overwrites a newer one (MV) |
| Stop MVVM cancelling the previous task | Keystrokes collapse, stale responses are dropped (MVVM) |
| Run MVI's debounce without its `EffectID` | Keystrokes collapse, a short query resets (MVI) |

There is no row for an MVI stale guard in this package, because there is no guard in the reducer to delete. It lives in MVIKit, and MVIKit's own test covers it.

## Choosing

- **MV** when a screen's async work is a single load with no races. `.task(id:)` is excellent, and a view model would be ceremony.
- **MVVM** when you want testable logic outside the view and the async work is modest. Write the cancellation carefully, once per view model.
- **MVI** when state has races, cancellation, or several sources to reconcile, as Cinematic's Search, Discover and Favorites do. You pay for structure once, and every feature gets the guarantees.

[TCA](https://github.com/pointfreeco/swift-composable-architecture) is MVI's shape with more machinery: dependency management, feature composition, and an exhaustive `TestStore` that fails a test on any unasserted state change. It isn't built here because it would bring a third-party dependency graph into a repository that has none. MVIKit is the smallest version of the same idea, so you can see what a framework adds on top.

## Run it

```bash
cd Package/CinematicComparison && swift test
```

The tests run on the macOS host in well under a second. Open `Package/CinematicComparison/Package.swift` in Xcode to see each version's SwiftUI preview. The app itself never links this package.
