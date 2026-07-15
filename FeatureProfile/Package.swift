// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureProfile",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FeatureProfile",
            targets: ["FeatureProfile"]
        )
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(url: "https://github.com/patrickridd/AuthDomain.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "FeatureProfile",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "AuthDomain", package: "AuthDomain")
            ],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "FeatureProfileTests",
            dependencies: [
                "FeatureProfile",
                .product(name: "AuthDomain", package: "AuthDomain")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
