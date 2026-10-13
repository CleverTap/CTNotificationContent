//
//  CTNotificationContentLogger.swift
//  CTNotificationContent
//
//  Copyright © 2026 CleverTap. All rights reserved.
//

import Foundation
import os.log

/// Logger used inside CTNotificationContent. Follows the CleverTap SDK log format, so each line reads
/// "[CleverTap]: [CTNotificationContent]: <Class>: <message>" under subsystem com.clevertap.CTNotificationContent.
/// Not intended to be called by apps.
@objc public final class CTNotificationContentLogger: NSObject {

    private static let tag = "[CleverTap]: [CTNotificationContent]"
    private static let osLog = OSLog(subsystem: "com.clevertap.CTNotificationContent", category: "CTNotificationContent")

    @objc public static func debug(_ message: String, caller: Any) {
        os_log("%{public}@: %{public}@: %{public}@", log: osLog, type: .debug, tag, className(caller), message)
    }

    @objc public static func info(_ message: String, caller: Any) {
        os_log("%{public}@: %{public}@: %{public}@", log: osLog, type: .info, tag, className(caller), message)
    }

    @objc public static func warn(_ message: String, caller: Any) {
        os_log("%{public}@: %{public}@: [WARN] %{public}@", log: osLog, type: .default, tag, className(caller), message)
    }

    @objc public static func error(_ message: String, caller: Any) {
        os_log("%{public}@: %{public}@: [ERROR] %{public}@", log: osLog, type: .error, tag, className(caller), message)
    }

    // Accepts an instance or a class, so static methods can pass self too.
    private static func className(_ caller: Any) -> String {
        if let cls = caller as? AnyClass {
            return String(describing: cls)
        }
        return String(describing: type(of: caller))
    }
}
