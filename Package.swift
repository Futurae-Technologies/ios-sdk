// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FuturaeKit",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "FuturaeKit", targets: ["FuturaeKit"])
    ],
    targets: [
        .binaryTarget(
          name: "FuturaeKit",
          url: "https://github.com/Futurae-Technologies/ios-sdk/releases/download/v2.3.2/FuturaeKit-v2.3.2.xcframework.zip",
          checksum: "3634afb8fc1d2cc8d1911511db3ae89394cfa268384df87f5b1b7e15e0191fa2"
        )
    ]
)
