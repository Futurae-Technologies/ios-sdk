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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.1.9/FuturaeKit-v3.1.9.xcframework.zip",
          checksum: "78795e49f649e63310618b06a5c4348dd3975fc4f7326a6a7a06e5086fcf1b3c"
        )
    ]
)
