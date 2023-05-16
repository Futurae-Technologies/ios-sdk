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
          url: "https://artifactory.futurae.com/artifactory/futurae-ios/FuturaeKit-v2.2.0.xcframework.zip",
          checksum: "37d68e2f7c7c9f012a2484a9e230bbec6b75e4bc9516d7850be9021e3e8f2cb4"
        )
    ]
)
