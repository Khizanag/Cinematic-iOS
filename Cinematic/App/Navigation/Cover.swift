import Foundation

/// Full-screen cover destinations.
enum Cover: Hashable, Identifiable {
    case trailer(url: URL)

    var id: Self { self }
}
