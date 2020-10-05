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
          url: "https://artifactory.futurae.com/artifactory/futurae-ios/FuturaeKit-v1.1.2.xcframework.zip",
          checksum: "8b4c5fb2de336ade15b23068863cb3dcedbe382c5d11b4d55ecd8c7f0fa6a8eb"
        )
    ]
)
