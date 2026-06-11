import CinematicDomain
import Foundation

func makeMovie(
    id: String = "1",
    title: String = "Movie Title",
    directorName: String = "Director",
    genreName: String = "Drama",
) -> Movie {
    Movie(
        id: Movie.ID(id),
        title: title,
        directorName: directorName,
        summary: "Summary",
        genreName: genreName,
    )
}

func makeMovieDetails(movie: Movie = makeMovie()) -> MovieDetails {
    MovieDetails(
        movie: movie,
        fullSummary: "Full summary",
        advisoryRating: "PG-13",
        duration: .seconds(5400),
        trailerURL: URL(string: "https://example.com/trailer.m4v"),
        storeURL: URL(string: "https://example.com/store"),
    )
}
