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
          checksum: "ad3eb1c80963ea6f5b1616d2b129d18177452e017d9738d81ffce77d3d948441"
        )
    ]
)
