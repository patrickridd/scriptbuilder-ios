// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureAuthKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FeatureAuthKit",
            targets: ["FeatureAuthKit"]
        )
    ],
    targets: [
        .target(
            name: "FeatureAuthKit"
        ),
        .testTarget(
            name: "FeatureAuthKitTests",
            dependencies: ["FeatureAuthKit"]
        )
    ]
)
