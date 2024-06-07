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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.14/FuturaeKit-v2.3.14.xcframework.zip",
          checksum: "f7f7f3bc6392253cba9e610fe62c31906b6b66a13c0bc1989f43031902af79de"
        )
    ]
)
