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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.7.1/FuturaeKit-v3.7.1.xcframework.zip",
            checksum: "c666c84d8590d584767156270720685e18ddb19f2ca9a6af7ffcc9bf6ca052b9"
        )
    ]
)