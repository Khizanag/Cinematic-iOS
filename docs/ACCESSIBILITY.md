# Accessibility

Accessibility is treated as a correctness requirement here, not a finishing pass. This is what the app does and how to verify it — a checklist you can copy into your own project.

## VoiceOver

- **Every interactive element has a label.** Buttons carry text or an explicit `accessibilityLabel` — the favorite toggle, the trailer close button, the About and store links.
- **Cards read as one element.** `MovieCard` and the favorites row use `.accessibilityElement(children: .combine)`, so VoiceOver announces "The Silent Voyage, Drama" as a single button instead of three fragments.
- **Activation is explained.** Movie buttons add `.accessibilityHint("Opens movie details")` so a VoiceOver user knows what a tap does before committing to it.
- **Decorative imagery is hidden.** `PosterImage` is `.accessibilityHidden(true)` — the poster is always paired with visible text, so the artwork is noise to a screen reader.
- **State and role are exposed.** `SectionHeader` adds the `.isHeader` trait; the favorite button adds `.isSelected` when the movie is a favorite, and pairs a `.sensoryFeedback(.selection)` with the toggle.

## Dynamic Type

All text uses `DesignSystem.Font.*`, which maps to the system text styles (`.body`, `.headline`, `.title`, …) and scales with the user's preferred size automatically. Poster dimensions are intentionally fixed — they are decorative frames, and the text beside them grows independently.

## Reduce Motion

The only continuous animation in the app is the skeleton shimmer. `SkeletonView` reads `@Environment(\.accessibilityReduceMotion)` and, when it is on, renders a static dimmed block instead of the pulsing `phaseAnimator`. There are no `repeatForever` animations anywhere — that is both a Reduce Motion courtesy and the fix for a real AsyncRenderer crash (see the commit history).

## Reduce Transparency

The trailer's close button is the one place a material (`.ultraThinMaterial`) is used directly. It reads `@Environment(\.accessibilityReduceTransparency)` and swaps to an opaque `DesignSystem.Color.cardBackground` when the setting is on. The system navigation and tab bars handle their own translucency.

## Hit targets

Interactive controls meet the 44×44 pt minimum. The trailer close button is sized to `DesignSystem.Size.Button.minimumTapTarget` explicitly; list rows and cards are comfortably larger.

## Localization

Accessibility strings are localized like every other string — hints, labels, and the loading announcement live in the per-module String Catalogs in English and German, never hard-coded. Price and date formatting is locale-aware through `FormatStyle`.

## How to verify

- **VoiceOver**: Settings → Accessibility → VoiceOver, then swipe through Discover, a detail screen, and the trailer.
- **Dynamic Type**: Settings → Accessibility → Display & Text Size → Larger Text, push it to the largest size, and confirm nothing truncates or overlaps.
- **Reduce Motion**: Settings → Accessibility → Motion → Reduce Motion — the skeletons should stop pulsing.
- **Reduce Transparency**: Settings → Accessibility → Display & Text Size → Reduce Transparency — the trailer close button should turn opaque.
- **German**: launch with `-AppleLanguages "(de)" -AppleLocale "de_DE"` to confirm the localized strings and formatting.
