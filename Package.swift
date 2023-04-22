// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "blobby-swift",
    products: [
        .library(
            name: "Blobby",
            targets: ["Blobby"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
        .package(url: "https://github.com/nixberg/tuple-sequences-swift", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Blobby",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "TupleSequences", package: "tuple-sequences-swift"),
                "Varint",
            ]),
        .target(
            name: "Varint"),
        .testTarget(
            name: "BlobbyTests",
            dependencies: [
                "Blobby",
            ]),
        .testTarget(
            name: "VarintTests",
            dependencies: [
                "Varint",
            ]),
    ]
)
