// This file exists solely to satisfy SPM's requirement that source targets
// contain at least one source file. It re-exports both CTNotificationContent
// (the pre-built xcframework) and SDWebImage so consumers get both by
// depending on the single "CTNotificationContent" product.
//
// NOTE: The SPM binaryTarget is named "CTNotificationContentBinary" to avoid
// a product name clash with this wrapper, but the module inside the xcframework
// is "CTNotificationContent" — that is the name used for import.
@_exported import CTNotificationContent
@_exported import SDWebImage
