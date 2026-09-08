import Foundation
import os.log

/// Writes SDK logs to the unified logging system.
///
/// A notification content extension runs in its own process. Xcode is normally
/// not attached to that process, so `print` output is lost. Logs written here
/// can be read in Console.app, and they are also included in a sysdiagnose.
///
/// The subsystem is shared with the CleverTap iOS SDK, so one filter shows
/// logs from both. Filter on the category to see only this SDK.
///
/// The name is deliberately different from `CTLogger` in the CleverTap iOS SDK.
/// Both frameworks are linked into the same extension process. Two classes with
/// the same Objective-C name would make the runtime pick one of them at random.
@objc(CTNotificationContentLogger)
public final class CTContentLog: NSObject {

    @objc public static let subsystem: String = "com.clevertap.sdk"
    @objc public static let category: String = "CTNotificationContent"

    /// Every line starts with this. `[CleverTap]` matches the prefix the
    /// CleverTap iOS SDK uses, so one text filter picks up both frameworks.
    /// `[NotificationContent]` tells the two apart.
    private static let prefix: String = "[CleverTap][NotificationContent]"

    private static let log = OSLog(subsystem: subsystem, category: category)

    /// Every line goes out at `.default`, including the ones from `error`.
    ///
    /// The system keeps `.info` and `.debug` messages in memory only. They are
    /// dropped before a client can collect them. `.default` messages are written
    /// to disk. A client can reproduce a problem and send us the log after.
    ///
    /// `CTLogger` in the CleverTap iOS SDK also sends every line at `.default`.
    /// One set of steps then works for both frameworks.
    static func info(_ message: String, file: String = #fileID, function: String = #function) {
        emit(message, location: callSite(file, function))
    }

    static func error(_ message: String, file: String = #fileID, function: String = #function) {
        emit(message, location: callSite(file, function))
    }

    private static func emit(_ message: String, location: String) {
        // The unified log hides %@ arguments by default. %{public}@ keeps them readable.
        os_log("%{public}@ %{public}@: %{public}@", log: log, type: .default, prefix, location, message)
    }

    /// Type and function the log came from, for example
    /// `CTCarouselController.showNext()`.
    private static func callSite(_ file: String, _ function: String) -> String {
        let name = (file as NSString).lastPathComponent
        let type = name.hasSuffix(".swift") ? String(name.dropLast(6)) : name
        return "\(type).\(function)"
    }

    /// Entry point for the Objective-C files. Swift callers should use `info`,
    /// which fills in the call site on its own.
    @objc(logInfo:from:)
    public static func logInfo(_ message: String, from location: String) {
        emit(message, location: location)
    }

    @objc(logError:from:)
    public static func logError(_ message: String, from location: String) {
        emit(message, location: location)
    }
}
