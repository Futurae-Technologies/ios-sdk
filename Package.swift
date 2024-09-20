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
        .package(url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.5.0/FuturaeKit-v2.5.0.xcframework.zip", .upToNextMajor(from: "0.15.3")),
        .package(url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.5.0/FuturaeKit-v2.5.0.xcframework.zip", .upToNextMajor(from: "6.7.1")),
    ],
    targets: [
        .binaryTarget(
            name: "FuturaeKit",
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.4.0/FuturaeKit-v3.4.0.xcframework.zip",
            checksum: "baedbc690dae46f657a62eb2eb90d91da501cbf44d791c921e9dc3d7a00f35cf"
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