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
          url: "https://artifactory.futurae.com/artifactory/futurae-ios/FuturaeKit-v2.1.0.xcframework.zip",
          checksum: "ce76ecc1aefcc1276ecca4c3b2a518d2cc342364ec648a62f835f3f914c438bf"
        )
    ]
)
