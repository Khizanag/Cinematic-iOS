# CLAUDE.md

Guidance for AI assistants and contributors working in this repository.

## What this is

Cinematic — a reference implementation of MVI + Clean Architecture in SwiftUI. iOS 26+, Swift 6, five local Swift packages under `Package/`, app target as composition root. The codebase is the documentation's proof: keep them in sync.

## Commands

```bash
# Lint — zero violations is the bar
swiftlint lint --strict

# Pure packages (fast, no simulator)
cd Package/MVIKit && swift test
cd Package/CinematicDomain && swift test
cd Package/CinematicData && swift test

# UI packages + app (iOS 26 simulator required)
xcodebuild test -scheme CinematicPresentation -destination 'platform=iOS Simulator,name=iPhone 17'
xcodebuild test -scheme CinematicDesign -destination 'platform=iOS Simulator,name=iPhone 17'
xcodebuild test -project Cinematic.xcodeproj -scheme Cinematic -destination 'platform=iOS Simulator,name=iPhone 17'
```

There is no workspace — always build with `-project` (or from a package directory). The deployment target is iOS 26, so the destination must be an iOS 26 simulator (`iPhone 17` family).

## Architecture map

| Layer | Location | Imports |
|---|---|---|
| Pattern core | `Package/MVIKit` | nothing |
| Domain | `Package/CinematicDomain` | nothing |
| Data | `Package/CinematicData` | Domain |
| Design system | `Package/CinematicDesign` | nothing |
| Features | `Package/CinematicPresentation` | Domain, MVIKit, Design |
| Composition + navigation | `Cinematic/` (app target) | everything |

Full reasoning: `docs/ARCHITECTURE.md`, `docs/MVI.md`. Recipe for new work: `docs/ADDING-A-FEATURE.md`.

## Hard rules

- The dependency rule is enforced by package manifests — never add `CinematicData` to the presentation package, or any new inward-pointing arrow.
- State changes only inside a `reduce` function. Async work is an `Effect`; results come back as intents.
- Never `NavigationLink` — destinations are `Screen`/`Sheet`/`Cover` cases routed by factories through the coordinators. Feature views emit closures, never navigate.
- Every visual value comes from a `DesignSystem.*` token; no hardcoded fonts, colors, spacings, or sizes.
- No user-facing string literals in feature code — String Catalog keys per module (`bundle: .module`).
- Loading UI is a per-screen skeleton mirroring the loaded layout; empty and error states use `ContentUnavailableView`.
- Swift Testing for unit tests; XCTest only in `CinematicUITests`.
- `swiftlint lint --strict` and a zero-warning build gate every commit. Fix causes, never bypass.
- Commits: imperative subject under 72 characters with a type prefix (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`, `ci:`). No AI attribution of any kind.

## Gotchas

- `Cinematic/Info.plist` exists only for `CFBundleURLTypes` (the `cinematic://` scheme) and merges over the generated Info.plist; everything else is `INFOPLIST_KEY_*` build settings.
- The project uses synchronized folders (`objectVersion 77`): adding a file is a filesystem operation, no `.pbxproj` edit. The only membership exception is `Info.plist`.
- DEBUG launch arguments: `-uiTestMode` swaps the composition root to in-memory doubles; `-deepLink cinematic://movie/<id>` routes at launch (used by the screenshot flow).
- The iTunes feeds have no text search — `searchMovies` filters a briefly cached full catalog inside the data layer. Don't "fix" callers around it.
