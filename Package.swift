// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FuturaeKit",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "FuturaeKit", targets: ["FuturaeKit"])
    ],
    targets: [
        .binaryTarget(
          name: "FuturaeKit",
          url: "https://artifactory.futurae.com/artifactory/futurae-ios/FuturaeKit-v1.1.5.xcframework.zip",
          checksum: "f736c19680e8c4bc223f736249c02e6a7bda8bbce3aad9179b990fe0ab4f6e34"
        )
    ]
)
