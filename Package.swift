// swift-tools-version: 5.6

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
                 .upToNextMajor(from: "3.0.0-alpha.21"))
    ],
    targets: [
        .target(
            name: "CareKitUtilities",
            dependencies: [
                .product(name: "CareKit", package: "CareKit"),
                .product(name: "CareKitStore", package: "CareKit"),
                .product(name: "CareKitUI", package: "CareKit")
            ]),
        .testTarget(
            name: "CareKitUtilitiesTests",
            dependencies: ["CareKitUtilities"])
    ]
)
