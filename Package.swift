// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FuturaeKit",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "FuturaeKit", targets: ["FuturaeKit"])
    ],
    targets: [
        .binaryTarget(
          name: "FuturaeKit",
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.7/FuturaeKit-v2.3.7.xcframework.zip",
          checksum: "c95571f2497d6d46c6fa696afbcd44b8cf9ef6fd8e2283539ebf14508447884b"
        )
    ]
)
