// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseData",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FirebaseData",
            targets: ["FirebaseData"]
        ),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "12.0.0"
        ),
    ],
    targets: [
        .target(
            name: "FirebaseData",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "FirebaseDataTests",
            dependencies: ["FirebaseData"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
