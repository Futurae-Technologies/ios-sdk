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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.12/FuturaeKit-v2.3.12.xcframework.zip",
          checksum: "e8d925de0cb1d2aae523926e153d51eaffac87b2d1acca8cca82914ad6321705"
        )
    ]
)
