// swift-tools-version: 6.2
// 6.2 is a deliberate floor: every Xcode 26 release can build this repo.
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
