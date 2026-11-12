// swift-tools-version: 6.4
// 6.4 is the floor: the repo builds with Xcode 27, locally and on CI.
import PackageDescription

// The app target's Approachable Concurrency, spelled out for SwiftPM: a
// nonisolated async function runs on its caller's actor unless it is
// `@concurrent`, and conformances of actor-isolated types are isolated.
let approachableConcurrency: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
    name: "CinematicDesign",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(name: "CinematicDesign", targets: ["CinematicDesign"]),
    ],
    targets: [
        .target(
            name: "CinematicDesign",
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ] + approachableConcurrency,
        ),
        .testTarget(
            name: "CinematicDesignTests",
            dependencies: ["CinematicDesign"],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ] + approachableConcurrency,
        ),
    ],
    swiftLanguageModes: [.v6],
)
