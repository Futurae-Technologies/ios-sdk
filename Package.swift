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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.9.9-rc2/FuturaeKit-v3.9.9-rc2.xcframework.zip",
            checksum: "aa4ee1d56792d435525f40402ea89fb5ca9382e9a51af91a8e473607dff29713"
        )
    ]
)