# CinematicDesign

Design tokens and the reusable components built from them. No business logic, no feature knowledge.

- `DesignSystem.{Color, Font, Spacing, Size, CornerRadius, Shadow, Motion}` — every visual value in the app routes through these. Colors are dynamic light/dark pairs.
- Components: `SkeletonView` (Reduce Motion-aware shimmer), `PosterImage` (2:3 posters with loading and placeholder states), `MovieCard`, `SectionHeader`, `FavoriteButton`.
- Components take resolved `String`s, not `LocalizedStringKey`s — keys resolve against the defining module's bundle, so callers localize in their own catalogs first.

```bash
xcodebuild test -scheme CinematicDesign -destination 'platform=iOS Simulator,name=iPhone 17'
```
