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
        .package(url: "https://github.com/Futurae-Technologies/SQLite.swift.git", .upToNextMajor(from: "0.15.3")),
        .package(url: "https://github.com/Futurae-Technologies/RxSwift", .upToNextMajor(from: "6.7.1")),
    ],
    targets: [
        .binaryTarget(
            name: "FuturaeKit",
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.2.4/FuturaeKit-v3.2.4.xcframework.zip",
            checksum: "86e58ff2d9e4d5373c5354b5b5d4a08af0876231939b766961c73417ea3570fd"
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