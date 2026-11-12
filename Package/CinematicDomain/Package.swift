// swift-tools-version: 6.4
// 6.4 is the floor: the repo builds with Xcode 27, locally and on CI.
import PackageDescription

// The domain layer is deliberately isolation-free: entities are `Sendable`
// values and use cases run wherever their caller does, so no default actor
// isolation is applied here.
// The app target's Approachable Concurrency, spelled out for SwiftPM: a
// nonisolated async function runs on its caller's actor unless it is
// `@concurrent`, and conformances of actor-isolated types are isolated.
let approachableConcurrency: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
    name: "CinematicDomain",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "CinematicDomain", targets: ["CinematicDomain"]),
    ],
    targets: [
        .target(
            name: "CinematicDomain",
            swiftSettings: approachableConcurrency,
        ),
        .testTarget(
            name: "CinematicDomainTests",
            dependencies: ["CinematicDomain"],
            swiftSettings: approachableConcurrency,
        ),
    ],
    swiftLanguageModes: [.v6],
)
