# CinematicComparison

Catalog search built three ways, MV, MVVM and MVI, over the same `SearchMoviesUseCase`, with one behavioural test suite held against each. The app never links this package; it exists to be read side by side. The walkthrough is [docs/COMPARISON.md](../../docs/COMPARISON.md).

- `MV/`: an `@Observable` model plus a view whose `.task(id:)` debounces and cancels.
- `MVVM/`: a view model that owns the query and its own search task.
- `MVI/`: a reducer on MVIKit's `Store`, the same state machine the app's Search feature runs.
- `Shared/SearchResultsView` renders every variant, so they differ only in wiring. It sets no visual values, which keeps the package free of the iOS-only design system and testable on the macOS host.

```bash
swift test
```
