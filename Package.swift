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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.9.5/FuturaeKit-v3.9.5.xcframework.zip",
            checksum: "e6d572f2d96c5327032c1eccd017777107f19c55241c5f0e44e52ba4deac754b"
        )
    ]
)