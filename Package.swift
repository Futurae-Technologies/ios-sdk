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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v1.7.0/FuturaeKit-v1.7.0.xcframework.zip",
            checksum: "5dcffc30dec88e49d30aefddd389d237d1e4fce4305cb5d2450cd68de7bb3ae0"
        )
    ]
)