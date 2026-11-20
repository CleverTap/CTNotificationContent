import Foundation
import os.log

/// Writes SDK logs to the unified logging system.
///
/// A notification content extension runs in its own process. Xcode is normally
/// not attached to that process, so `print` output is lost. Logs written here
/// can be read in Console.app.
/// TODO(verify): whether a sysdiagnose includes these lines. Apple's sysdiagnose
/// instructions PDF needs a developer login and was not read.
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
    /// `[CTNotificationContent]` tells the two apart, and matches `category`.
    private static let prefix: String = "[CleverTap][CTNotificationContent]"

    private static let log = OSLog(subsystem: subsystem, category: category)

    /// The level values are the same as `CleverTapLogLevel` in the CleverTap
    /// iOS SDK.
    ///
    /// - `-1` turns every line off. This is the default. Versions before 2.0.0
    ///   logged nothing, so an app that only updates the SDK keeps a quiet
    ///   device log.
    /// - `0` writes a short trail for each push, which template was picked,
    ///   what it fell back to and why, plus every error. No line at this level
    ///   holds payload values or notification text. A url shows only its
    ///   scheme and host, see `loggableURL(_:)`.
    /// - `1` adds the `debug` lines. Those hold the whole payload, full urls,
    ///   each image download, and anything that repeats during a render.
    ///
    /// The SDK does not check for a debug build itself. For SPM it ships as a
    /// prebuilt binary, so a compile time flag inside the SDK would not follow
    /// the app's build configuration. The app decides, for example by calling
    /// `setDebugLevel(1)` inside `#if DEBUG`.
    private static var debugLevel: Int32 = -1

    /// Sets the log level. Pass -1 for off (the default), 0 for the short
    /// trail and errors, 1 for verbose.
    ///
    /// Call this inside the notification content extension, not in the
    /// `AppDelegate` of the app. The extension is a separate process with its
    /// own copy of this value. A call in the app cannot reach it. The right
    /// place is your `CTNotificationViewController` subclass, before
    /// `super.viewDidLoad()`.
    @objc public static func setDebugLevel(_ level: Int32) {
        debugLevel = level
        info("Debug level set to \(level)")
    }

    @objc public static func getDebugLevel() -> Int32 {
        return debugLevel
    }

    /// A url as it may appear in a log line.
    ///
    /// Level 0 lines are kept on disk, and image urls and deeplinks can hold
    /// user ids, emails, tokens or coupon codes in the path or the query.
    /// So at level 0 only the scheme and host are written. That is
    /// still enough to tell http from https, or to spot a CDN that is down.
    /// At level 1 the whole url is written.
    ///
    /// Use this for every url in an `info` or `error` line. A `debug` line can
    /// print the url as it is, since it only runs at level 1.
    @objc(loggableURL:)
    public static func loggableURL(_ urlString: String) -> String {
        if debugLevel > 0 {
            return urlString
        }
        if urlString.isEmpty {
            return "[empty]"
        }
        guard let components = URLComponents(string: urlString), let scheme = components.scheme else {
            return "[unparseable, \(urlString.count) chars]"
        }
        // A url like mailto:name@example.com has no host. Its path is the
        // personal part, so only the scheme is kept.
        let schemeAndHost = components.host.map { "\(scheme)://\($0)" } ?? "\(scheme):"
        let hasMore = !components.path.isEmpty || components.query != nil || components.fragment != nil
        return hasMore ? "\(schemeAndHost) [rest hidden]" : schemeAndHost
    }

    /// Every line goes out at `.default`, including the ones from `error`.
    ///
    /// The system keeps `.info` and `.debug` messages in memory only. They are
    /// dropped before a client can collect them. `.default` messages are written
    /// to disk. A client can reproduce a problem and send us the log after.
    ///
    /// `CTLogger` in the CleverTap iOS SDK also sends every line at `.default`.
    /// One set of steps then works for both frameworks.
    static func info(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function) {
        guard debugLevel >= 0 else { return }
        emit(message(), location: callSite(file, function))
    }

    static func error(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function) {
        guard debugLevel >= 0 else { return }
        emit(message(), location: callSite(file, function))
    }

    /// Detail that is too noisy, or too personal, to write on every push.
    ///
    /// Nothing is written unless `setDebugLevel` was called with 1 or more.
    /// Use this for whole payloads, for deeplink urls, for layout numbers, and
    /// for anything that repeats many times in one render.
    static func debug(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function) {
        guard debugLevel > 0 else { return }
        emit(message(), location: callSite(file, function))
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
        guard debugLevel >= 0 else { return }
        emit(message, location: location)
    }

    @objc(logError:from:)
    public static func logError(_ message: String, from location: String) {
        guard debugLevel >= 0 else { return }
        emit(message, location: location)
    }

    @objc(logDebug:from:)
    public static func logDebug(_ message: String, from location: String) {
        guard debugLevel > 0 else { return }
        emit(message, location: location)
    }
}
