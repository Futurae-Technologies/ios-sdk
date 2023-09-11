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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.3/FuturaeKit-v2.3.3.xcframework.zip",
          checksum: "47c1c6372b1bb3e64b751175fafb105c3ea131c57f992243bc8aaaf878525b8f"
        )
    ]
)
