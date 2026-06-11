// swift-tools-version: 6.2
// 6.2 is a deliberate floor: every Xcode 26 release can build this repo.
import PackageDescription

// The domain layer is deliberately isolation-free: entities are `Sendable`
// values and use cases run wherever their caller does, so no default actor
// isolation is applied here.
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
        .target(name: "CinematicDomain"),
        .testTarget(
            name: "CinematicDomainTests",
            dependencies: ["CinematicDomain"],
        ),
    ],
    swiftLanguageModes: [.v6],
)
