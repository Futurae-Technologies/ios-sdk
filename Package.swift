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
            checksum: "6007ed3b6cc048987a52b1394ab790a603cedd1cadd7695b1f575c886a5189aa"
        )
    ]
)