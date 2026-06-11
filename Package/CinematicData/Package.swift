// swift-tools-version: 6.2
import PackageDescription

// The data layer is isolation-free like the domain it implements: repositories
// are `Sendable` and the API client is an `actor`, so no default actor
// isolation is applied here.
let package = Package(
    name: "CinematicData",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "CinematicData", targets: ["CinematicData"]),
    ],
    dependencies: [
        .package(path: "../CinematicDomain"),
    ],
    targets: [
        .target(
            name: "CinematicData",
            dependencies: [
                .product(name: "CinematicDomain", package: "CinematicDomain"),
            ],
        ),
        .testTarget(
            name: "CinematicDataTests",
            dependencies: ["CinematicData"],
        ),
    ],
    swiftLanguageModes: [.v6],
)
