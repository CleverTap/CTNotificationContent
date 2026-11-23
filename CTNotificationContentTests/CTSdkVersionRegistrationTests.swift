import XCTest
@testable import CTNotificationContent

/// Stand-in for CleverTap core. Like core, setCustomSdkVersion only writes a
/// static and never reads self. The test target does not link core, so this is
/// the only class named CleverTap in the process.
@objc(CleverTap)
final class FakeCleverTapCore: NSObject {
    static var versions: [String: Int32] = [:]
    static var instancesCreated = 0

    override init() {
        FakeCleverTapCore.instancesCreated += 1
        super.init()
    }

    @objc func setCustomSdkVersion(_ name: String, version: Int32) {
        FakeCleverTapCore.versions[name] = version
    }
}

/// Tests that the version is handed to core without creating a core instance.
final class CTSdkVersionRegistrationTests: XCTestCase {

    func testRegistersNameAndVersionWithoutCreatingAnInstance() {
        // +load ran before this test bundle loaded, when there was no CleverTap
        // class yet, so it is run again here now that the stand-in exists.
        FakeCleverTapCore.versions = [:]
        FakeCleverTapCore.instancesCreated = 0

        CTNotificationViewController.perform(NSSelectorFromString("registerSdkVersionWithCleverTapCore"))

        XCTAssertEqual(FakeCleverTapCore.versions["CTNotificationContent"], 20000)
        // An instance here would mean sharedInstance was called, which locks in
        // the Info.plist account before setCredentialsWithAccountID:.
        XCTAssertEqual(FakeCleverTapCore.instancesCreated, 0)
    }
}
