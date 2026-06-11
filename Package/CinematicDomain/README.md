# CinematicDomain

The center of the dependency graph: entities, use cases, and repository contracts. Imports nothing; everything else points here.

- Entities are plain `Sendable` values — no `Codable`, no API vocabulary. `Movie.ID` is a dedicated type so identifiers can't be confused with other strings.
- `MovieError` travels via typed throws (`async throws(MovieError)`) from repository to reducer.
- Use cases own the business rules: concurrent genre loading with per-row degradation (`FetchDiscoverCatalogUseCase`), query hygiene (`SearchMoviesUseCase`), subscribe-before-snapshot streaming (`ObserveFavoritesUseCase`).
- `MovieCatalogRepository` and `FavoritesRepository` are the contracts the data layer implements and tests stub.

```bash
swift test
```
