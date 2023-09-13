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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.4/FuturaeKit-v2.3.4.xcframework.zip",
          checksum: "e78f2fd5a8d20b66b112104fa71b6b94604fc939b0068b33384bfcdc8d1e9835"
        )
    ]
)
