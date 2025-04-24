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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.6.6/FuturaeKit-v3.6.6.xcframework.zip",
            checksum: "92d871a51cab9629636cde392bca001b4587023970150b8b0c903fc462801b82"
        )
    ]
)