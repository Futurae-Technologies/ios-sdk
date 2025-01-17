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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.6.3/FuturaeKit-v3.6.3.xcframework.zip",
            checksum: "204840ebc720f9a119c5ce63e9dfea13b8452cce59e6994802ba02e6f9b13be3"
        )
    ]
)