# Accessibility

Accessibility is treated as a correctness requirement here, not a finishing pass. This is what the app does and how to verify it — a checklist you can copy into your own project.

## VoiceOver

- **Every interactive element has a label.** Buttons carry text or an explicit `accessibilityLabel` — the favorite toggle, the trailer close button, the About and store links.
- **Cards read as one element.** `MovieCard` and the favorites row use `.accessibilityElement(children: .combine)`, so VoiceOver announces "The Silent Voyage, Drama" as a single button instead of three fragments.
- **Activation is explained.** Movie buttons add `.accessibilityHint("Opens movie details")` so a VoiceOver user knows what a tap does before committing to it.
- **Decorative imagery is hidden.** `PosterImage` is `.accessibilityHidden(true)` — the poster is always paired with visible text, so the artwork is noise to a screen reader.
- **State and role are exposed.** `SectionHeader` adds the `.isHeader` trait; the favorite button adds `.isSelected` when the movie is a favorite, and pairs a `.sensoryFeedback(.selection)` with the toggle.

## Dynamic Type

All text uses `DesignSystem.Font.*`, which maps to the system text styles (`.body`, `.headline`, `.title`, …) and scales with the user's preferred size automatically.

Text that scales still needs room to land. At accessibility sizes a single word such as "Silent" is wider than a 110 pt card, so:

- **Cards widen.** `DesignSystem.Size.Poster.card(_:at:)` returns at least `accessibilityCard` (280 pt) at accessibility sizes. Discover's rows, the search grid and their skeletons all size from it, so titles wrap between words instead of inside them.
- **Every card reserves the same text height.** `MovieCard` reserves two title lines and one caption line at regular sizes, and three and two at accessibility sizes, even when a card has no caption. A lazy carousel sizes its row from the first card it lays out, so a taller card after it would otherwise be squeezed and cut short. At regular sizes a longer title truncates by design: VoiceOver reads the whole title and the detail screen shows it.
- **Empty and error titles wrap.** `ContentUnavailableView` truncates its title to one line. `unavailableTitle()` lets it wrap, and `unavailableDescription()` draws the description in `DesignSystem.Color.textSecondary`, which meets contrast where the view's default gray only nearly does.

## Reduce Motion

The only continuous animation in the app is the skeleton shimmer. `SkeletonView` reads `@Environment(\.accessibilityReduceMotion)` and, when it is on, renders a static dimmed block instead of the pulsing `phaseAnimator`. There are no `repeatForever` animations anywhere — that is both a Reduce Motion courtesy and the fix for a real AsyncRenderer crash (see the commit history).

## Reduce Transparency

The trailer's close button is the one place a material (`.ultraThinMaterial`) is used directly. It reads `@Environment(\.accessibilityReduceTransparency)` and swaps to an opaque `DesignSystem.Color.cardBackground` when the setting is on. The system navigation and tab bars handle their own translucency.

## Hit targets

Interactive controls meet the 44×44 pt minimum. The trailer close button and the detail screen's store link are sized to `DesignSystem.Size.Button.minimumTapTarget` explicitly; list rows and cards are comfortably larger.

## Localization

Accessibility strings are localized like every other string — hints, labels, and the loading announcement live in the per-module String Catalogs in English and German, never hard-coded. Price and date formatting is locale-aware through `FormatStyle`.

## The automated audit

[`AccessibilityAuditTests`](https://github.com/Khizanag/Cinematic-iOS/blob/main/CinematicUITests/AccessibilityAuditTests.swift) runs Xcode's accessibility audit (contrast, hit targets, clipped text, missing labels, Dynamic Type support) on every screen: Discover, a movie's details, the trailer, empty favorites, search, and search results. It runs once at the default text size and once at the largest accessibility size, and fails on any issue.

The audit reads pixels, so it also judges what nobody can see. A row scrolled beneath the floating tab bar reads as low contrast, and a carousel card peeking past the screen edge reads as clipped. The test counts an issue only when its element is fully on screen, outside a cut-off card, and clear of system chrome (the tab bar, the search field, the keyboard), which the app doesn't draw.

Its first runs found five real problems, all fixed: the store link's 18 pt hit area, truncated card titles and captions, a truncated empty-state title, an empty-state description that only nearly passed contrast, and a price VoiceOver read as a bare "$14.99" with no context. The last one surfaced only on CI's older Xcode, whose audit checks differ from newer ones; the test names the failing element, so a CI-only failure is traceable from the log.

CI runs the audit on iPhone. Run locally on iPad, it found the squeezed cards above, which on iPhone sit off screen until you scroll. It also reports iPad-only system elements, such as the floating keyboard suggestion bar, so the iPad run is a manual check rather than a gate.

Two things it can't judge. A word broken in the middle still counts as fitting, so the card widths are held by `DesignTokenTests` instead. And no audit checks that VoiceOver's reading order makes sense, so that stays a manual pass.

## How to verify

- **Automated audit**: `xcodebuild test -project Cinematic.xcodeproj -scheme Cinematic -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:CinematicUITests/AccessibilityAuditTests`

- **VoiceOver**: Settings → Accessibility → VoiceOver, then swipe through Discover, a detail screen, and the trailer.
- **Dynamic Type**: Settings → Accessibility → Display & Text Size → Larger Text, push it to the largest size, and confirm nothing truncates or overlaps.
- **Reduce Motion**: Settings → Accessibility → Motion → Reduce Motion — the skeletons should stop pulsing.
- **Reduce Transparency**: Settings → Accessibility → Display & Text Size → Reduce Transparency — the trailer close button should turn opaque.
- **German**: launch with `-AppleLanguages "(de)" -AppleLocale "de_DE"` to confirm the localized strings and formatting.
