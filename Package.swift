// swift-tools-version: 5.5.2

import PackageDescription

let package = Package(
    name: "CareKitUtilities",
    platforms: [.iOS(.v14), .macOS(.v12), .watchOS(.v7)],
    products: [
        .library(
            name: "CareKitUtilities",
            targets: ["CareKitUtilities"])
    ],
    dependencies: [
        .package(url: "https://github.com/cbaker6/CareKit.git",
                 .upToNextMajor(from: "2.1.8"))
    ],
    targets: [
        .target(
            name: "CareKitUtilities",
            dependencies: [
                .product(name: "CareKit", package: "CareKit"),
                .product(name: "CareKitStore", package: "CareKit")
            ]),
        .testTarget(
            name: "CareKitUtilitiesTests",
            dependencies: ["CareKitUtilities"])
    ]
)
