// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FuturaeKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "FuturaeKit", targets: ["FuturaeKit", "FuturaeKitUmbrella"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.4.2/FuturaeKit-v2.4.2.xcframework.zip", .upToNextMajor(from: "0.14.1")),
        .package(url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.4.2/FuturaeKit-v2.4.2.xcframework.zip", .upToNextMajor(from: "6.6.0")),
    ],
    targets: [
        .binaryTarget(
            name: "FuturaeKit",
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.2.2/FuturaeKit-v3.2.2.xcframework.zip",
            checksum: "157f9306856be9f6907cd9d5dd8af2c0290797ffb7f2efbac7ecea2c11825df6"
        ),
        .target(
            name: "FuturaeKitUmbrella",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "SQLite", package: "SQLite.swift"),
            ]
        )
    ]
)