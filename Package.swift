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
          url: "https://artifactory.futurae.com/artifactory/futurae-ios/FuturaeKit-v2.3.0.xcframework.zip",
          checksum: "671cf5e107809f116d2ccbaa7bdca1955a5bcec69f06ca8ed6ceaf16edb09dba"
        )
    ]
)
