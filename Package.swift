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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.4.0/FuturaeKit-v3.4.0.xcframework.zip",
            checksum: "baedbc690dae46f657a62eb2eb90d91da501cbf44d791c921e9dc3d7a00f35cf"
        )
    ]
)