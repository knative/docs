// swift-tools-version:6.4

import PackageDescription

let package = Package(
  name: "HelloSwift",
  dependencies: [
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.28.0")
  ],
  targets: [
    .executableTarget(
      name: "HelloSwift",
      dependencies: [.product(name: "Hummingbird", package: "hummingbird")]
    )
  ]
)
