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
          url: "https://artifactory.futurae.com/artifactory/futurae-ios/FuturaeKit-v1.1.4.xcframework.zip",
          checksum: "20d0be29f5aac050b7bff9e2c0dc2aa6944d8a110b761714e06b39e5bdf076d2"
        )
    ]
)
