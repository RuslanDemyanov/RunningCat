// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RunningCatMenuBar",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "RunningCatMenuBar",
            targets: ["RunningCatMenuBar"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.0.0")
    ],
    targets: [
        .executableTarget(
            name: "RunningCatMenuBar",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
