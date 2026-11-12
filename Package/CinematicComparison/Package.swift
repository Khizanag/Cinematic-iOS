// swift-tools-version: 6.4
// 6.4 is the floor: the repo builds with Xcode 27, locally and on CI.
import PackageDescription

// One feature, catalog search, built three ways over the same use case. The
// app never links this package: it exists to be read side by side and to run
// one behavioural test suite against every variant. It sets no visual values,
// so it needs no design system and tests on the macOS host.
// The app target's Approachable Concurrency, spelled out for SwiftPM: a
// nonisolated async function runs on its caller's actor unless it is
// `@concurrent`, and conformances of actor-isolated types are isolated.
let approachableConcurrency: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
    name: "CinematicComparison",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "CinematicComparison", targets: ["CinematicComparison"]),
    ],
    dependencies: [
        .package(path: "../CinematicDomain"),
        .package(url: "https://github.com/Khizanag/MVIKit", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "CinematicComparison",
            dependencies: [
                .product(name: "CinematicDomain", package: "CinematicDomain"),
                .product(name: "MVIKit", package: "MVIKit"),
            ],
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ] + approachableConcurrency,
        ),
        .testTarget(
            name: "CinematicComparisonTests",
            dependencies: ["CinematicComparison"],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ] + approachableConcurrency,
        ),
    ],
    swiftLanguageModes: [.v6],
)
