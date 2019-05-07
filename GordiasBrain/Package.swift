// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GordiasBrain",
    products: [
        .library(
            name: "GordiasBrain",
            targets: ["GordiasBrain"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GordiasBrain",
            dependencies: []),
        .testTarget(
            name: "GordiasBrainTests",
            dependencies: ["GordiasBrain"]),
    ]
)
