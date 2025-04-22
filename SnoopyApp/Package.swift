// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnoopyApp",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "SnoopyApp",
            targets: [
                "SnoopyApp"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vmanot/Swallow.git", branch: "master")
    ],
    targets: [
        .target(
            name: "SnoopyApp",
            dependencies: [
                "Swallow"
            ]
        ),
        .testTarget(
            name: "SnoopyAppTests",
            dependencies: ["SnoopyApp"],
            resources: [
                .process("Dummy data")
            ]
        ),
    ]
)
