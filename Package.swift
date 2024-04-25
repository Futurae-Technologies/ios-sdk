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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.10/FuturaeKit-v2.3.10.xcframework.zip",
          checksum: "25bb9600488fee388cbd1649e829fd4aa3847002f27be7fbc30f99b8ddab449c"
        )
    ]
)
