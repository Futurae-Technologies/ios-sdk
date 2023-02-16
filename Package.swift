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
          url: "https://artifactory.futurae.com/artifactory/futurae-ios/FuturaeKit-v2.0.4.xcframework.zip",
          checksum: "f030ac7057c4806c1a56d2ef914a2453cc19a61577ab93851b6fa6e2639ed905"
        )
    ]
)
