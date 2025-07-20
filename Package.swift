// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TinyObjects",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .visionOS(.v1),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces
        // making them visible to other packages.
        .library(
            name: "TinyObjects",
            targets: ["TinyObjects"]
        ),
    ],
    dependencies: [
        // Quick and Nimble for testing
        .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
        .package(url:  "https://github.com/Quick/Nimble.git", from: "13.7.1"),

        // SwiftLintPlugins for linting using SPM Build Tool Plugin
        // See the README for reasons to use the dedecated plugins repo rather than SwiftLint repo.
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", from: "0.59.1"),

        // SwiftFormat for formatting using SPM Build Tool Plugin
        .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.56.4"),
    ],
    targets: [
        .target(
            name: "TinyObjects"
        ),
        .testTarget(
            name: "TinyObjectsTests",
            dependencies: [
                "TinyObjects",
                "Quick",
                "Nimble",
            ]
        ),
    ]
)
