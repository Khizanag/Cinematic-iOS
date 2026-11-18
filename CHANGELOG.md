# Changelog

Notable changes to Cinematic. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Siri and Shortcuts. Get Top Movies (overall or for one genre) answers without opening the app and hands its movies to the next action. Open Movie and Show Favorites jump into the app. Each has ready-made phrases in English and German.
- `FetchTopMoviesUseCase`, for surfaces that need one short chart instead of the whole Discover catalog.

## [1.1.0] - 2026-11-18

### Added

- A genre filter on Discover, in a toolbar menu with one symbol per genre. The selected genre shows as the navigation subtitle.
- A layered Liquid Glass app icon made in Icon Composer, with default, dark, tinted and clear appearances. `Scripts/app-icon.py` regenerates it.
- An iPad layout: the tab bar can become a sidebar, and the detail screen keeps its text to a readable column.
- `CinematicComparison`, a package that builds the Search feature three ways (MV, MVVM and MVI), measured side by side in [`docs/COMPARISON.md`](docs/COMPARISON.md).
- Accessibility audits on every screen at two text sizes, which name the failing element.
- `Scripts/device.sh`, which builds, signs, installs and launches a dev build on a real device.

### Changed

- Builds with Xcode 27 and Swift 6.4 tools, with approachable concurrency in every module, on [MVIKit 1.1.0](https://github.com/Khizanag/MVIKit/releases/tag/1.1.0).
- Loading skeletons now have the exact size of the cards they stand in for, at every text size.
- The system scroll edge effect, the shared close button on the trailer, and label-colored toolbar icons replace custom versions.

### Fixed

- Choosing a genre no longer shifts the grid down.
- Cards in a row share one text height, and text stays whole at accessibility sizes.
- The price on the detail screen has a VoiceOver label, and every control meets the minimum hit target.

## [1.0.0] - 2026-09-29

The first tagged release: Discover, Search, Movie detail with trailer playback, and Favorites. Built on five layered Swift packages with the MVI loop from MVIKit, typed throws, coordinator navigation with deep links, an offline cache, English and German String Catalogs, and Swift Testing at every layer.

[Unreleased]: https://github.com/Khizanag/Cinematic-iOS/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/Khizanag/Cinematic-iOS/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Khizanag/Cinematic-iOS/releases/tag/v1.0.0
