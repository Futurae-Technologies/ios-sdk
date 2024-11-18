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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.5.0/FuturaeKit-v3.5.0.xcframework.zip",
            checksum: "b4ec52c0eec68e0a8f8fe7fb9355980a42da54482da66d43e529b33635f4091d"
        )
    ]
)