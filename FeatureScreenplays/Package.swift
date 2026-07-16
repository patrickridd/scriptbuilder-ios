// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureScreenplays",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FeatureScreenplays",
            targets: ["FeatureScreenplays"]
        )
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "FeatureScreenplays",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "DesignSystem", package: "DesignSystem")
            ],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "FeatureScreenplaysTests",
            dependencies: ["FeatureScreenplays"]
        )
    ],
    swiftLanguageModes: [.v6]
)
