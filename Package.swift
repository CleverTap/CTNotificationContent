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
        .target(
            name: "CTNotificationContent",
            path: "CTNotificationContent",
            exclude: ["Info.plist"],
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("./"),
                .headerSearchPath("ContentSlider/"),
                .headerSearchPath("Views/"),
                .headerSearchPath("Categories/")
            ],
            linkerSettings: [
                .linkedFramework("UserNotifications"),
                .linkedFramework("UIKit")
            ]
        )
    ]
)
