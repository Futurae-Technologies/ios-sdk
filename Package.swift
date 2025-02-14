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
            checksum: "ed48c0ff665bcd1c34c19964c4fe4522c35b29cc62abf37210848720b8afd592"
        )
    ]
)