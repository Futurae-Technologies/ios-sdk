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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.6.5/FuturaeKit-v3.6.5.xcframework.zip",
            checksum: "9d44982ca133a132e9bd269b077927187f3b8c52af2056c61f76cde0ab44b929"
        )
    ]
)