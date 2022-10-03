// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FuturaeKit",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "FuturaeKit", targets: ["FuturaeKit"])
    ],
    targets: [
        .binaryTarget(
          name: "FuturaeKit",
          url: "https://artifactory.futurae.com/artifactory/futurae-ios/FuturaeKit-v2.0.0.xcframework.zip",
          checksum: "52e239d2d160ab316a3b2cd8ca85b5f549bee0f539e2301cbb08c48a1002747e"
        )
    ]
)
