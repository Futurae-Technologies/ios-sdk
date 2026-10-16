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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.9.9-rc1/FuturaeKit-v3.9.9-rc1.xcframework.zip",
            checksum: "04ce5b6e8a7920acd6a0f68cd37e50dea302140387dc1f4103689bdf65b120e5"
        )
    ]
)