// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FuturaeKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "FuturaeKit", targets: ["FuturaeKit"]),
    ],
    targets: [
        .binaryTarget(
            name: "FuturaeKit",
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.6.0/FuturaeKit-v3.6.0.xcframework.zip",
            checksum: "a2a2dde5de64947801474b1695a79f7b9b770190d7ddc5f29ab582735a14a690"
        )
    ]
)