// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FuturaeKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "FuturaeKit", targets: ["FuturaeKit"]),
    ],
    targets: [
        .binaryTarget(
            name: "FuturaeKit",
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.4.2/FuturaeKit-v2.4.2.xcframework.zip",
            checksum: "14940b91f2a098610e4db066bbd5cd0d995cf8a6fe8ba6fd653ac1d3dec7ab3c"
        )
    ]
)