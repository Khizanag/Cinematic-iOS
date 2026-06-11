// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MVIKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "MVIKit", targets: ["MVIKit"]),
    ],
    targets: [
        .target(
            name: "MVIKit",
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ],
        ),
        .testTarget(
            name: "MVIKitTests",
            dependencies: ["MVIKit"],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ],
        ),
    ],
    swiftLanguageModes: [.v6],
)
