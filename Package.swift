// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftUIDebugTools",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SwiftUIDebugTools",
            targets: ["SwiftUIDebugTools"]),
    ],
    targets: [
        .target(
            name: "SwiftUIDebugTools",
            dependencies: []),
        .testTarget(
            name: "SwiftUIDebugToolsTests",
            dependencies: ["SwiftUIDebugTools"]),
    ]
)