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
            checksum: "58f08155109d3cc662f12ddcd333a36b71b16521b98290ad6e260ff18a19465b"
        )
    ]
)