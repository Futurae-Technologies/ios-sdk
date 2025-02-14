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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.6.4/FuturaeKit-v3.6.4.xcframework.zip",
            checksum: "aa91605f7ad3ca3090169ad7737b1afb064077bc87691f4cfad7331089709a45"
        )
    ]
)