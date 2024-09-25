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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.4.1/FuturaeKit-v2.4.1.xcframework.zip",
            checksum: "434565f7bd03f0f3a5494df34383c348661dfb64d32d0fac71881f36abe5f612"
        )
    ]
)