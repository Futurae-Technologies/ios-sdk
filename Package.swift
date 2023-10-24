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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.6/FuturaeKit-v2.3.6.xcframework.zip",
          checksum: "0f0e5882dcb4a3a7a95329760f81ad17e88df151e74200a7434251e5621a7805"
        )
    ]
)
