// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AuthDomain",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AuthDomain",
            targets: ["AuthDomain"]
        ),
    ],
    targets: [
        .target(
            name: "AuthDomain"
        ),
        .testTarget(
            name: "AuthDomainTests",
            dependencies: ["AuthDomain"]
        ),
    ]
)
