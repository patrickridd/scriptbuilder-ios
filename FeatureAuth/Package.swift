// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureAuth",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FeatureAuth",
            targets: ["FeatureAuth"]
        )
    ],
    dependencies: [
        .package(path: "../AuthDomain")
    ],
    targets: [
        .target(
            name: "FeatureAuth",
            dependencies: [
                .product(name: "AuthDomain", package: "AuthDomain")
            ],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "FeatureAuthTests",
            dependencies: ["FeatureAuth"]
        )
    ]
)
