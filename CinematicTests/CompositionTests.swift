@testable import Cinematic
import CinematicDomain
import Foundation
import Testing

@MainActor
struct CompositionTests {
    @Test("Preview dependencies execute a use case end to end")
    func previewDependenciesWork() async throws {
        let dependencies = AppDependencies.preview()

        let catalog = try await dependencies.fetchDiscoverCatalog.execute()

        #expect(!catalog.featured.isEmpty)
    }

    @Test("Deep links route to the movie detail screen on the discover tab")
    func deepLinkRoutes() throws {
        let coordinator = AppCoordinator()
        coordinator.selectedTab = .favorites
        let url = try #require(URL(string: "cinematic://movie/42"))

        coordinator.handle(url)

        #expect(coordinator.selectedTab == .discover)
        #expect(coordinator.coordinator(for: .discover).path == [.movieDetail(id: Movie.ID("42"))])
    }

    @Test("Unrelated URLs are ignored")
    func unrelatedURLIsIgnored() throws {
        let coordinator = AppCoordinator()
        let url = try #require(URL(string: "https://example.com/movie/42"))

        coordinator.handle(url)

        #expect(coordinator.coordinator(for: .discover).path.isEmpty)
    }

    @Test("Each tab keeps an isolated navigation stack")
    func tabStacksAreIsolated() {
        let coordinator = AppCoordinator()

        coordinator.coordinator(for: .search).push(.movieDetail(id: Movie.ID("1")))

        #expect(coordinator.coordinator(for: .search).path.count == 1)
        #expect(coordinator.coordinator(for: .discover).path.isEmpty)
        #expect(coordinator.coordinator(for: .favorites).path.isEmpty)
    }
}
