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
            targets: ["CTNotificationContent"])
    ],
    targets: [
        .binaryTarget(
            name: "CTNotificationContent",
            path: "Framework/CTNotificationContent.xcframework"
        ),
    ]
)