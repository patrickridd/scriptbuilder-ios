// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeaturePaywall",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FeaturePaywall",
            targets: ["FeaturePaywall"]
        )
    ],
    dependencies: [
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "FeaturePaywall",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem")
            ],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "FeaturePaywallTests",
            dependencies: ["FeaturePaywall"]
        )
    ]
)
