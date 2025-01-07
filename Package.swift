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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.6.2/FuturaeKit-v3.6.2.xcframework.zip",
            checksum: "708c1464588f3c8a0fd7f04d8bf52367f68fd1c026b3106edb75c256634436e1"
        )
    ]
)