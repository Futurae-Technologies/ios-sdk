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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.6.4/FuturaeKit-v2.6.4.xcframework.zip",
            checksum: "08879c29fdb75d1708d758e6fb2ba36e2b1a57f8cb9ea4a4ee378fc6b83a1aa4"
        )
    ]
)