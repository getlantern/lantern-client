// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DBModule",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "DBModule",
      targets: ["DBModule"])
  ],
  dependencies: [
    .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .binaryTarget(
      name: "Internalsdk",
      path: "../macos/internalsdk/Internalsdk.xcframework"),
    .target(
      name: "DBModule",
      dependencies: [
        "Internalsdk",
        .product(name: "SQLite", package: "SQLite.swift"),
      ]),
    .testTarget(
      name: "DBModuleTests",
      dependencies: ["DBModule"]),
  ]
)
