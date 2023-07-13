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
          url: "https://artifactory.futurae.com/artifactory/futurae-ios/FuturaeKit-v2.3.1.xcframework.zip",
          checksum: "35ab1511a793a6444674e5307958337ccdf961f665db8efb21701eea3894cb1a"
        )
    ]
)
