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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.2/FuturaeKit-v2.3.2.xcframework.zip",
          checksum: "61cd0d2f2fdab8c6da3d831f999154f97c77f1a891681061ba1ec1be5c7f9048"
        )
    ]
)