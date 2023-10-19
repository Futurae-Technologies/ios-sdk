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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.5/FuturaeKit-v2.3.5.xcframework.zip",
          checksum: "a5a82162fe05431fb23d08abfacc94e260f19355112c49fa50297d730df78f2f"
        )
    ]
)
