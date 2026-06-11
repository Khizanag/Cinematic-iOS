import CinematicDomain
import Testing

struct FavoritesUseCaseTests {
    @Test("Toggling reports the new favorite state both ways")
    func toggleRoundTrip() async {
        let stub = StubFavoritesRepository()
        let useCase = ToggleFavoriteUseCase(repository: stub)
        let movie = makeMovie()

        #expect(await useCase.execute(movie: movie))
        #expect(await stub.isFavorite(movie.id))
        #expect(await !useCase.execute(movie: movie))
        #expect(await !stub.isFavorite(movie.id))
    }

    @Test("Observation emits the current list first, then every change")
    func observeEmitsInitialThenChanges() async {
        let stub = StubFavoritesRepository()
        let movie = makeMovie()
        let stream = ObserveFavoritesUseCase(repository: stub).execute()
        var iterator = stream.makeAsyncIterator()

        #expect(await iterator.next()?.isEmpty == true)

        await stub.toggle(movie)
        #expect(await iterator.next() == [movie])

        await stub.toggle(movie)
        #expect(await iterator.next()?.isEmpty == true)
    }

    @Test("Details use case surfaces the repository's record")
    func detailsDelegate() async throws {
        var stub = StubMovieCatalogRepository()
        stub.detailsResult = .success(makeMovieDetails())

        let details = try await FetchMovieDetailsUseCase(repository: stub).execute(id: Movie.ID("1"))

        #expect(details == makeMovieDetails())
    }
}
