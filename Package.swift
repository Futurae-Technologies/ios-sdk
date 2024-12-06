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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.6.1/FuturaeKit-v3.6.1.xcframework.zip",
            checksum: "fe317c8ba786fe7765639b44eac52a85cbc9eb6efa22a8ae91c6e067c2fe3236"
        )
    ]
)