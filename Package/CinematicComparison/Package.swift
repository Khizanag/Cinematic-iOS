// swift-tools-version: 6.2
// 6.2 is a deliberate floor: every Xcode 26 release can build this repo.
import PackageDescription

// One feature, catalog search, built three ways over the same use case. The
// app never links this package: it exists to be read side by side and to run
// one behavioural test suite against every variant. It sets no visual values,
// so it needs no design system and tests on the macOS host.
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
        .package(url: "https://github.com/Khizanag/MVIKit", from: "1.0.1"),
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
            ],
        ),
        .testTarget(
            name: "CinematicComparisonTests",
            dependencies: ["CinematicComparison"],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ],
        ),
    ],
    swiftLanguageModes: [.v6],
)
