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
          checksum: "17fc78372663e208f33dd0b3586adf3fe4034a5edc416d037b297372216d8182"
        )
    ]
)
