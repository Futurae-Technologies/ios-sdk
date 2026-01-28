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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.9.4/FuturaeKit-v3.9.4.xcframework.zip",
            checksum: "74a8d1445b03d4e6d99734427794740272269687805081ff87b2aa58d7dd12a7"
        )
    ]
)