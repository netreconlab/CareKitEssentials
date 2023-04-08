// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "CareKitUtilities",
    platforms: [.iOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "CareKitUtilities",
            targets: ["CareKitUtilities"])
    ],
    dependencies: [
        .package(url: "https://github.com/cbaker6/CareKit.git",
                 .upToNextMajor(from: "3.0.0-alpha.1"))
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
