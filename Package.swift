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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.7.0/FuturaeKit-v3.7.0.xcframework.zip",
            checksum: "37e339837b543d1457e7d06ee795b4c81d12cc20dafbdf1d974bf8c5eacbf419"
        )
    ]
)