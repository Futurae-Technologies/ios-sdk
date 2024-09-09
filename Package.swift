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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.3.0/FuturaeKit-v3.3.0.xcframework.zip",
            checksum: "e15ac3273fccd6af59a801519831a79935d1b390ddc633f7558b1c0a9b908835"
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