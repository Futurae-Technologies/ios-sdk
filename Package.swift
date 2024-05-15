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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.13/FuturaeKit-v2.3.13.xcframework.zip",
          checksum: "bd433820eb6bc9f57a14216deab7189129943009c023b90a430a7263c5acf8e4"
        )
    ]
)
