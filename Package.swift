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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.6.0/FuturaeKit-v2.6.0.xcframework.zip",
            checksum: "6ab6695d04cb6a9bd23ce5e4d93c6f3421c15ffcf1e5812b7bb1a242073f9979"
        )
    ]
)