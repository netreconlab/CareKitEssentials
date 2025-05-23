// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CareKitEssentials",
	defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v14), .watchOS(.v10)],
    products: [
        .library(
            name: "CareKitEssentials",
            targets: ["CareKitEssentials"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/cbaker6/CareKit.git",
            .upToNextMajor(from: "3.1.3")
        )
    ],
    targets: [
        .target(
            name: "CareKitEssentials",
            dependencies: [
                .product(
                    name: "CareKit",
                    package: "CareKit"
                ),
                .product(
                    name: "CareKitStore",
                    package: "CareKit"
                ),
                .product(
                    name: "CareKitUI",
                    package: "CareKit"
                )
            ]
        ),
        .testTarget(
            name: "CareKitEssentialsTests",
            dependencies: ["CareKitEssentials"]
        )
    ]
)
