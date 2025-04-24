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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.6.3/FuturaeKit-v2.6.3.xcframework.zip",
            checksum: "1f2ca0b269b7cd2178167274fc004324bd2171cc4b430f084994e38d13f697e2"
        )
    ]
)