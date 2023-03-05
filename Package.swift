// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-terminal",
  products: [
    .library(name: "Terminal", targets: ["Terminal"]),
    .library(name: "Termlib", targets: ["Termlib"]),
    .library(name: "Termcaps", targets: ["Termcaps"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-system", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
  ],
  targets: [
    .systemLibrary(name: "Termlib"),
    .target(
      name: "Terminal",
      dependencies: [
        .product(name: "SystemPackage", package: "swift-system"),
        .product(name: "Tagged", package: "swift-tagged"),
        "Termcaps"
      ]
    ),
    .target(
      name: "Termcaps",
      dependencies: [
        .product(name: "SystemPackage", package: "swift-system"),
        "Termlib"
      ]
    ),
  ]
)
