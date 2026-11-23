import XCTest
@testable import CTNotificationContent

/// Tests for the log level the SDK starts at, and for how urls are trimmed at
/// each level.
final class CTContentLogTests: XCTestCase {

    override func tearDown() {
        // The level is shared by every test in the process. Put the default
        // back so the next test starts where an app would.
        CTContentLog.setDebugLevel(-1)
        super.tearDown()
    }

    func testLogsAreOffByDefault() {
        // An app that updates the SDK and never calls setDebugLevel must get
        // no log lines, the same as versions before logging was added.
        XCTAssertEqual(CTContentLog.getDebugLevel(), -1)
    }

    func testLevelZeroKeepsOnlySchemeAndHost() {
        CTContentLog.setDebugLevel(0)

        XCTAssertEqual(CTContentLog.loggableURL("https://cdn.example.com/users/42/coupon.png?token=abc"),
                       "https://cdn.example.com [rest hidden]")
        XCTAssertEqual(CTContentLog.loggableURL("https://cdn.example.com"), "https://cdn.example.com")
        XCTAssertEqual(CTContentLog.loggableURL("mailto:name@example.com"), "mailto: [rest hidden]")
        XCTAssertEqual(CTContentLog.loggableURL("http://[::1"), "[unparseable, 11 chars]")
        XCTAssertEqual(CTContentLog.loggableURL(""), "[empty]")
    }

    func testLevelOneKeepsTheWholeURL() {
        CTContentLog.setDebugLevel(1)

        let fullURL = "https://cdn.example.com/users/42/coupon.png?token=abc"
        XCTAssertEqual(CTContentLog.loggableURL(fullURL), fullURL)
    }
}
