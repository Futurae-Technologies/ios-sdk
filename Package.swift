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
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.9/FuturaeKit-v2.3.9.xcframework.zip",
          checksum: "e09674317948b297788f0d6924575ebec6b92268c3cfba2408aa4ac35f75e045"
        )
    ]
)
