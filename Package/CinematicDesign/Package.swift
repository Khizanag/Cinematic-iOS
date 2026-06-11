// swift-tools-version: 6.2
// 6.2 is a deliberate floor: every Xcode 26 release can build this repo.
import PackageDescription

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
            ],
        ),
        .testTarget(
            name: "CinematicDesignTests",
            dependencies: ["CinematicDesign"],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ],
        ),
    ],
    swiftLanguageModes: [.v6],
)
