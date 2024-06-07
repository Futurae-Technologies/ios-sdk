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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.2.0/FuturaeKit-v3.2.0.xcframework.zip",
          checksum: "b93d94315de8c3396304f3a24d3a5734237a1a2a1508fbb9cf62bb87cfb4e654"
        )
    ]
)
