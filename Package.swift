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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.6.0/FuturaeKit-v2.6.0.xcframework.zip",
            checksum: "a38f631d099c7d92a45b6aefd8ff76382d9a375a11ccf5d31597ff0043338c3e"
        )
    ]
)