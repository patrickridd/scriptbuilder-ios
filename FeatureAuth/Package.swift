// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureAuth",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FeatureAuth",
            targets: ["FeatureAuth"]
        )
    ],
    targets: [
        .target(
            name: "FeatureAuth"
        ),
        .testTarget(
            name: "FeatureAuthTests",
            dependencies: ["FeatureAuth"]
        )
    ]
)
