@testable import CinematicData
import CinematicDomain
import Foundation
import Testing

struct UserDefaultsFavoritesRepositoryTests {
    @Test("Toggling stores newest-first and reports the new state")
    func toggleStoresNewestFirst() async {
        let suiteName = makeSuiteName()
        defer { tearDown(suiteName) }
        let repository = UserDefaultsFavoritesRepository(suiteName: suiteName)

        await repository.toggle(makeMovie(id: "1", title: "First"))
        await repository.toggle(makeMovie(id: "2", title: "Second"))

        let titles = await repository.favorites().map(\.title)
        #expect(titles == ["Second", "First"])
        #expect(await repository.isFavorite(Movie.ID("1")))
    }

    @Test("Favorites survive a relaunch (a fresh repository instance)")
    func favoritesPersistAcrossInstances() async {
        let suiteName = makeSuiteName()
        defer { tearDown(suiteName) }
        let movie = makeMovie()
        await UserDefaultsFavoritesRepository(suiteName: suiteName).toggle(movie)

        let relaunched = UserDefaultsFavoritesRepository(suiteName: suiteName)

        #expect(await relaunched.favorites() == [movie])
    }

    @Test("Every change is broadcast to open streams")
    func changesAreBroadcast() async {
        let suiteName = makeSuiteName()
        defer { tearDown(suiteName) }
        let repository = UserDefaultsFavoritesRepository(suiteName: suiteName)
        let movie = makeMovie()

        let stream = await repository.changes()
        var iterator = stream.makeAsyncIterator()
        await repository.toggle(movie)

        #expect(await iterator.next() == [movie])
    }
}

// MARK: - Helpers
private extension UserDefaultsFavoritesRepositoryTests {
    func makeSuiteName() -> String {
        "favorites-tests-\(UUID().uuidString)"
    }

    func tearDown(_ suiteName: String) {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
    }
}
