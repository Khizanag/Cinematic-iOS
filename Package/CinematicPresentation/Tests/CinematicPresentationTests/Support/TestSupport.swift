import CinematicDomain
import Foundation
import Testing

/// Polls until `condition` holds, yielding between checks — for asserting on
/// state fed by long-lived streams, where `Store.settle()` would never return.
///
/// The timeout only bounds a failure: a passing check returns as soon as the
/// condition holds. It is generous because loaded CI simulators run parallel
/// tests many times slower than a desk machine.
@MainActor
func waitUntil(
    timeout: Duration = .seconds(10),
    _ condition: () -> Bool,
) async {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while !condition() {
        guard clock.now < deadline else {
            Issue.record("Timed out waiting for condition")
            return
        }
        try? await Task.sleep(for: .milliseconds(5))
    }
}

/// A catalog where every request fails the same way.
struct FailingCatalogRepository: MovieCatalogRepository {
    var error: MovieError = .offline

    func topMovies() async throws(MovieError) -> [Movie] {
        throw error
    }

    func topMovies(in genre: MovieGenre) async throws(MovieError) -> [Movie] {
        throw error
    }

    func searchMovies(matching query: String) async throws(MovieError) -> [Movie] {
        throw error
    }

    func movieDetails(for id: Movie.ID) async throws(MovieError) -> MovieDetails {
        throw error
    }
}
