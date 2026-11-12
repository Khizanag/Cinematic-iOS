// swift-tools-version: 6.2
// 6.2 is a deliberate floor: every Xcode 26 release can build this repo.
import PackageDescription

// Note what is missing: CinematicData. The presentation layer depends on
// domain abstractions only — concrete data sources are injected by the app's
// composition root. The package graph enforces the Clean dependency rule.
// The app target's Approachable Concurrency, spelled out for SwiftPM: a
// nonisolated async function runs on its caller's actor unless it is
// `@concurrent`, and conformances of actor-isolated types are isolated.
let approachableConcurrency: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
    name: "CinematicPresentation",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(name: "CinematicPresentation", targets: ["CinematicPresentation"]),
    ],
    dependencies: [
        .package(path: "../CinematicDesign"),
        .package(path: "../CinematicDomain"),
        .package(url: "https://github.com/Khizanag/MVIKit", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "CinematicPresentation",
            dependencies: [
                .product(name: "CinematicDesign", package: "CinematicDesign"),
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
            name: "CinematicPresentationTests",
            dependencies: ["CinematicPresentation"],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ] + approachableConcurrency,
        ),
    ],
    swiftLanguageModes: [.v6],
)
