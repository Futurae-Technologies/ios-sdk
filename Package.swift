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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.6.4/FuturaeKit-v3.6.4.xcframework.zip",
            checksum: "6286ed5e4e97181df65357ddcc7e7df264c1f4d965f6c50e3976105323a886d3"
        )
    ]
)