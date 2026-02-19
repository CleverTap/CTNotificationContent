// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CTNotificationContent",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "CTNotificationContent",
            targets: ["CTNotificationContentWrapper"])
    ],
    dependencies: [
        // SDWebImage is listed here so SPM resolves it as a single shared dependency.
        // If another package in the app also adds SDWebImage with the same URL,
        // SPM deduplicates it automatically — no conflicts.
        .package(
            url: "https://github.com/SDWebImage/SDWebImage.git",
            from: "5.11.0"
        ),
    ],
    targets: [
        // The pre-built xcframework binary — cannot have dependencies itself.
        .binaryTarget(
            name: "CTNotificationContentBinary",
            path: "Framework/CTNotificationContent.xcframework"
        ),
        // Thin wrapper source target that re-exports the binary and pulls in SDWebImage.
        // This is the standard SPM pattern for adding dependencies alongside a binaryTarget.
        .target(
            name: "CTNotificationContentWrapper",
            dependencies: [
                "CTNotificationContentBinary",
                .product(name: "SDWebImage", package: "SDWebImage"),
            ],
            path: "Sources/CTNotificationContentWrapper"
        ),
    ]
)