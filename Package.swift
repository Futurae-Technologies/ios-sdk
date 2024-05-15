// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FuturaeKit",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "FuturaeKit", targets: ["FuturaeKit"])
    ],
    targets: [
        .binaryTarget(
          name: "FuturaeKit",
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.1.8/FuturaeKit-v3.1.8.xcframework.zip",
          checksum: "ffb4ddaf04198a2104fcbb4c1d466d7b86e357cbf821435fee4b30dbc6768b88"
        )
    ]
)
