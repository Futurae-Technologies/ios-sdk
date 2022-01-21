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
          url: "https://artifactory.futurae.com/artifactory/futurae-ios/FuturaeKit-v1.6.0.xcframework.zip",
          checksum: "225a3af482054091f8d3fadf622a01ff532c5b5bb2597de2b8d9a1dbb870f7e2"
        )
    ]
)
