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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.9.6/FuturaeKit-v3.9.6.xcframework.zip",
            checksum: "7ac5ec6c3dc309607c90b4ca8f9715f786eda8f3338e92831cc18093b1c80789"
        )
    ]
)