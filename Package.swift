// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FuturaeKit",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "FuturaeKit", targets: ["FuturaeKit"])
    ],
    targets: [
        .binaryTarget(
          name: "FuturaeKit",
          url: "https://artifactory.futurae.com/artifactory/futurae-ios/FuturaeKit-v1.5.0.xcframework.zip",
          checksum: "a9c2105ea84b8e376b03a3038a4f933f15d762c423aa145423e9ab3895a76079"
        )
    ]
)
