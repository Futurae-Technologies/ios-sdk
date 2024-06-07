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
          checksum: "0d005c307c4d31d2119aa3dadea3df4465c369ba0ca8d1b0b29bff927d7ab3db"
        )
    ]
)
