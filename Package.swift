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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.6/FuturaeKit-v2.3.6.xcframework.zip",
          checksum: "5dc4d940f5a1681788e243bbc54d8a1bfbead6bf658ebeca5885136a37ee4af9"
        )
    ]
)
