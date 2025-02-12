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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.6.1/FuturaeKit-v2.6.1.xcframework.zip",
            checksum: "454dfc9cb4699694a5b27532a145d8a6fa550f24d7f1495e67d8c02aebb39969"
        )
    ]
)