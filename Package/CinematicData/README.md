# CinematicData

Everything Apple-API-specific, contained. Implements the domain contracts over the iTunes RSS feeds and lookup endpoint.

- `ITunesEndpoint` — all URL construction in one place.
- `APIClient` (actor) — fetch + decode, converting `URLError`/`DecodingError` to `MovieError` at the boundary with field-naming diagnostics.
- DTOs mirror the wire format exactly, including the feed's single-or-array `entry` quirk; `MovieMapper` and `ArtworkURL` translate to domain entities (with high-resolution poster rewriting).
- `ITunesMovieCatalogRepository` — charts, lookup, and local search over a briefly cached full catalog (the feeds have no search endpoint; the quirk stops here).
- `CachedMovieCatalogRepository` — offline decorator serving the last good answer from a JSON `DiskCache`.
- `UserDefaultsFavoritesRepository` (actor) — persistence plus `AsyncStream` change broadcasting.

Tests run the production `URLSession` path against a `URLProtocol` stub.

```bash
swift test
```
