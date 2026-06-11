# Architecture

How Cinematic is put together and why. Read this before changing structure; read [MVI.md](MVI.md) for the pattern inside each feature.

## The dependency rule

Clean Architecture reduces to one sentence: source-code dependencies point only inward, toward policy. In this project "inward" means toward `CinematicDomain`, and the rule is not a convention — it is enforced by the package graph. A build, not a review comment, fails when someone breaks it.

| Layer | Package | May import | Holds |
|---|---|---|---|
| Pattern | `MVIKit` | nothing | `Store`, `Reducer`, `Effect`, `Send`, `LoadingPhase` |
| Domain | `CinematicDomain` | nothing | Entities, use cases, repository protocols, `MovieError` |
| Data | `CinematicData` | Domain | `APIClient`, DTOs, mappers, repositories, caching |
| Design | `CinematicDesign` | nothing | `DesignSystem` tokens, reusable components |
| Presentation | `CinematicPresentation` | Domain, MVIKit, Design | Reducers, views, skeletons, strings |
| App | `Cinematic` target | everything | Composition root, navigation, About |

Two absences carry most of the meaning:

- **Presentation never imports Data.** Reducers depend on use cases; use cases depend on repository protocols; the app decides which implementation satisfies them.
- **Domain imports nothing.** Entities are plain values — no `Codable`, no API names, no persistence hints. The wire format and the stored format each have their own DTOs in the data layer.

## The domain layer

Entities are small and honest: `Movie` (with a typed `Movie.ID` so an identifier can't be confused with any other string), `MovieDetails` (an aggregate over `Movie` for the fields only lookup provides), `DiscoverCatalog`, `Price` (a `Decimal`, never a `Double`).

Use cases own business rules so neither reducers nor repositories grow them:

- `FetchDiscoverCatalogUseCase` — the featured chart is required; genre rows load concurrently in a `TaskGroup`, degrade row-by-row, and keep declared order regardless of network race.
- `SearchMoviesUseCase` — trims input and short-circuits queries under two characters.
- `ObserveFavoritesUseCase` — subscribes *before* snapshotting, so a toggle racing the first read is buffered instead of lost.
- `FetchMovieDetailsUseCase`, `ToggleFavoriteUseCase` — thin by design; a use case that only delegates is still the seam where a rule would land tomorrow.

Errors are domain vocabulary. `MovieError` is `Hashable` and travels through typed throws (`async throws(MovieError)`) from repository to reducer, which keeps feature states `Equatable` and reducer tests value-for-value.

## The data layer

Everything Apple-specific stops here.

- `ITunesEndpoint` builds every URL in one reviewable place.
- `APIClient` is an `actor`; it converts `URLError` and `DecodingError` into `MovieError` at the boundary, with decode diagnostics that name the offending field.
- The RSS DTOs mirror the wire format exactly — `im:` keys, label wrappers, and an `entry` that may be an array, a single object, or absent. The weirdness is contained and tested.
- `ITunesMovieCatalogRepository` absorbs the API's biggest gap: the feeds have no text search, so search loads the full catalog (top chart + every genre, deduplicated, briefly cached in an actor) and filters locally with diacritic-insensitive matching and prefix-first ranking. Callers just see `searchMovies`.
- `CachedMovieCatalogRepository` is a textbook decorator: same protocol in and out, persists every success as JSON under `Caches/`, and falls back to the stored copy when the wrapped repository fails. Composed in one line by the app.
- `UserDefaultsFavoritesRepository` (an `actor`) persists favorites and broadcasts every change to all open `AsyncStream` subscriptions. Subscription registration happens inside the actor *before* the stream is returned — the API is `func changes() async` precisely so no emission can be missed.

`StoredMovie` is the persistence DTO shared by the cache and favorites. Domain entities stay `Codable`-free; a storage schema change is a data-layer migration, not a domain edit.

## The composition root

`AppDependencies` (in the app target) is the only type that constructs concrete repositories:

```swift
static func live() -> AppDependencies {
    AppDependencies(
        catalog: CachedMovieCatalogRepository(
            wrapping: ITunesMovieCatalogRepository(client: APIClient()),
        ),
        favorites: UserDefaultsFavoritesRepository(),
    )
}
```

`preview()` swaps both repositories for in-memory doubles from `CinematicPresentation/PreviewSupport` — the same doubles drive Xcode previews, reducer tests, and the `-uiTestMode` launch argument. One fixture set for the whole project.

Dependencies reach views through a SwiftUI `@Entry` environment value, and the factories pull from it when building screens.

## Navigation

The coordinator pattern lives entirely in the app target: `AppCoordinator` owns one `TabCoordinator` per tab; `Screen`, `Sheet`, and `Cover` enums name every destination; factories map them to views. `CoordinatedNavigationStack` is the only place `.navigationDestination`, `.sheet`, and `.fullScreenCover` appear.

Feature views are deliberately navigation-agnostic. They emit events — `onSelectMovie`, `onPlayTrailer` — and the factories translate those into coordinator calls. That keeps every feature previewable and testable in isolation, and it means "where does tapping a movie lead?" has exactly one answer, in one file.

Deep links follow the same path: `cinematic://movie/<id>` lands in `AppCoordinator.handle(_:)`, which selects a tab and pushes a screen like any other caller.

## Concurrency

The isolation story is deliberate and layered:

- `MVIKit`, `CinematicDesign`, `CinematicPresentation`, and the app build with **default MainActor isolation** (`defaultIsolation(MainActor.self)`) — UI state lives on the main actor without annotation noise. Pure data types that must cross isolation (`Effect`, `Send`, `LoadingPhase`, preview fixtures) are explicitly `nonisolated`.
- `CinematicDomain` and `CinematicData` are **isolation-free**: entities and use cases are `Sendable` values that run wherever their caller does, and shared mutable state is owned by actors (`APIClient`, `CatalogSearchIndex`, `DiskCache`, the favorites repository).
- Effects run as plain tasks; the only way back into state is `Send`, which hops to the main actor and drops intents from cancelled effects.

## Trade-offs, named

- **Use-case structs over protocol-per-use-case.** Use cases are concrete structs depending on repository protocols. Tests substitute repositories, not use cases — one seam instead of two. If a use case ever needs polymorphism, introduce the protocol then.
- **Search is local filtering.** The honest cost of a keyless, zero-setup API. The repository hides it behind the domain contract, so swapping in an API with server-side search changes one file. Treat it as the exercise it is.
- **Navigation events over navigation-in-state.** Some MVI codebases route inside reducers. Here, pure navigation is a view-to-coordinator concern and reducers manage screen state only — see [MVI.md](MVI.md#what-belongs-in-an-intent) for the reasoning.
- **`UserDefaults` for favorites.** A small user-owned list read at launch does not need a database. The repository protocol is the insurance: moving to SwiftData later touches the composition root and one file in the data layer.

## FAQ

**Why five packages instead of folders?** Folders ask politely; manifests enforce. The compiler rejecting `import CinematicData` inside a reducer is the entire point.

**Why does `MVIKit` not depend on the app at all?** It is the reusable pattern, not the app. Copy the package into another project and it works unchanged.

**Where are the view models?** There are none. The `Store` + `Reducer` pair plays that role with a stricter contract: state only changes in `reduce`, and every change has a named cause.

**Why is `CinematicDesign` not imported by the domain?** Tokens are presentation policy. The domain doesn't know the app has a screen.
