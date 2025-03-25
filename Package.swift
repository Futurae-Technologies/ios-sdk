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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.6.2/FuturaeKit-v2.6.2.xcframework.zip",
            checksum: "fa6bb370311c23d98378799db5be62c736d02b80f2a11341ce327a9d57a56df3"
        )
    ]
)