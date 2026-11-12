// swift-tools-version: 6.2
// 6.2 is a deliberate floor: every Xcode 26 release can build this repo.
import PackageDescription

// The data layer is isolation-free like the domain it implements: repositories
// are `Sendable` and the API client is an `actor`, so no default actor
// isolation is applied here.
// The app target's Approachable Concurrency, spelled out for SwiftPM: a
// nonisolated async function runs on its caller's actor unless it is
// `@concurrent`, and conformances of actor-isolated types are isolated.
let approachableConcurrency: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

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
            swiftSettings: approachableConcurrency,
        ),
        .testTarget(
            name: "CinematicDataTests",
            dependencies: ["CinematicData"],
            swiftSettings: approachableConcurrency,
        ),
    ],
    swiftLanguageModes: [.v6],
)
