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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.4.0/FuturaeKit-v2.4.0.xcframework.zip",
          checksum: "30e520b8c9e720619548f194957105a0f1714873cb8f902c29aae5469ee67953"
        )
    ]
)
