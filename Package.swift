// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyNetwork",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SwiftyNetwork",
            targets: ["SwiftyNetwork"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftyNetwork"
        ),
        .testTarget(
            name: "SwiftyNetworkTests",
            dependencies: ["SwiftyNetwork"]
        ),
    ]
)
