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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.8/FuturaeKit-v2.3.8.xcframework.zip",
          checksum: "2d293193630a4e8134d90ba653272c286edde901b4f8ac1f1b60e9e60f05978c"
        )
    ]
)
