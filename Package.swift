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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.11/FuturaeKit-v2.3.11.xcframework.zip",
          checksum: "46a0b9497e658daad2edbd69d8855344eaa106208ea224af84630fb9f302e86e"
        )
    ]
)
