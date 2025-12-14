// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CareKitEssentials",
	defaultLocalization: "en",
    platforms: [.iOS("18.0"), .macOS("15.0"), .watchOS("11.0")],
    products: [
        .library(
            name: "CareKitEssentials",
            targets: ["CareKitEssentials"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/cbaker6/CareKit.git",
            .upToNextMajor(from: "4.0.5")
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
