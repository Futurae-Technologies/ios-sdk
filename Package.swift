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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.5.0/FuturaeKit-v2.5.0.xcframework.zip",
            checksum: "294fb6642e48cee69a4e5242cbbd3a2c4415681f04006f552f0ef04ef9461156"
        )
    ]
)