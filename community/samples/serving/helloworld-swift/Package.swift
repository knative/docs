// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "HelloSwift",
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.4.5"))
    ],
    targets: [
        .target(
        name: "HelloSwift",
        dependencies: ["Swifter"],
        path: "./Sources")
    ]
)
