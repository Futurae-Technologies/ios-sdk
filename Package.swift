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
            url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v3.9.7-rc1/FuturaeKit-v3.9.7.xcframework.zip",
            checksum: "bd98ba74125ebd17f743c65d2f341bcc688d5143654c37c6407971526747e8e2"
        )
    ]
)