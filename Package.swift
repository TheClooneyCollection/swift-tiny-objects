// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TinyObjects",
    products: [
        // Products define the executables and libraries a package produces
        // making them visible to other packages.
        .library(
            name: "TinyObjects",
            targets: ["TinyObjects"]),
    ],
    dependencies: [
        // Quick and Nimble for testing
        .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.7.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TinyObjects"),
        .testTarget(
            name: "TinyObjectsTests",
            dependencies: [
                "TinyObjects",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
    ]
)
