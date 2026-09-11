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

    /// Controls the extra lines from `debug`. Zero keeps them off.
    ///
    /// `info` and `error` never look at this value. Those two are always on.
    /// The whole point of this SDK's logs is a client who already hit a bug
    /// and cannot be asked to turn anything on and try again.
    ///
    /// This matches `CTLogger` in the CleverTap iOS SDK. There an info line
    /// passes on any level, and a debug line needs a level above zero.
    private static var debugLevel: Int32 = 0

    /// Turns the extra `debug` lines on. Pass 1 or more.
    ///
    /// Call this inside the notification content extension, not in the
    /// `AppDelegate` of the app. The extension is a separate process with its
    /// own copy of this value. A call in the app cannot reach it. The right
    /// place is your `CTNotificationViewController` subclass, before
    /// `super.viewDidLoad()`.
    @objc public static func setDebugLevel(_ level: Int32) {
        debugLevel = level
        emit("Debug level set to \(level)", location: "CTContentLog.setDebugLevel")
    }

    @objc public static func getDebugLevel() -> Int32 {
        return debugLevel
    }

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

    /// Detail that is too noisy to write on every push.
    ///
    /// Nothing is written unless `setDebugLevel` was called with 1 or more.
    /// Use this for whole payloads, for layout numbers, and for anything that
    /// repeats many times in one render.
    static func debug(_ message: String, file: String = #fileID, function: String = #function) {
        guard debugLevel > 0 else { return }
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

    @objc(logDebug:from:)
    public static func logDebug(_ message: String, from location: String) {
        guard debugLevel > 0 else { return }
        emit(message, location: location)
    }
}
