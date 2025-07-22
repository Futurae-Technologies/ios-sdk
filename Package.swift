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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.6.5/FuturaeKit-v2.6.5.xcframework.zip",
            checksum: "f8f5573444088643fe5d4bfff9e8c36c4be61c2c281c6f632fd56bd2426a8c06"
        )
    ]
)