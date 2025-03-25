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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v1.7.1/FuturaeKit-v1.7.1.xcframework.zip",
            checksum: "661652a014dd86e6362f2708ad638a9b1779fed41cdecc6796551c41b894ac7f"
        )
    ]
)