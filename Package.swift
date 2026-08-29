// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Pocket",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Pocket",
            path: "Sources/Pocket"
        ),
        .testTarget(
            name: "PocketTests",
            dependencies: ["Pocket"],
            path: "Tests/PocketTests"
        ),
    ]
)
