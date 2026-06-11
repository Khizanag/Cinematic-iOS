# CinematicPresentation

The four features, one folder each: Discover, Search, MovieDetail, Favorites (plus the trailer player). Each feature is a reducer-driven state machine and a small view tree.

- Depends on `CinematicDomain`, `MVIKit`, and `CinematicDesign` — never on `CinematicData`. Concrete data sources arrive through use cases injected by the app's composition root.
- Views are navigation-agnostic: they emit events (`onSelectMovie`, `onPlayTrailer`) and the app decides what they mean.
- Per-screen skeletons mirror loaded layouts; empty and error states are `ContentUnavailableView`s; all strings live in this package's String Catalog.
- `PreviewSupport` ships public in-memory doubles shared by previews, the reducer tests, and the app's `-uiTestMode`.

```bash
xcodebuild test -scheme CinematicPresentation -destination 'platform=iOS Simulator,name=iPhone 17'
```
