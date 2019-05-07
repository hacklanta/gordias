// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GordiasChat",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "GordiasChat",
            targets: ["GordiasChat"]),
    ],
    dependencies: [
        .package(path: "../GordiasBrain"),
        ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GordiasChat",
            dependencies: ["GordiasBrain"]),
        .testTarget(
            name: "GordiasChatTests",
            dependencies: ["GordiasChat"]),
    ]
)
