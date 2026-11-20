import XCTest
import UIKit
@testable import CTNotificationContent

/// Tests for the timer template's countdown, covering what users see while it
/// runs and expires, and that it stops once its notification has closed.
///
/// None of these payloads has an image url, so no test touches the network.
final class CTTimerTemplateControllerTests: XCTestCase {

    // MARK: - Helpers

    private func makeController(templateFields: [String: Any],
                                deliveredAt deliveryDate: Date = Date()) throws -> CTTimerTemplateController {
        var fields: [String: Any] = [
            "pt_title": "Running title",
            "pt_msg": "Running message",
            "pt_title_alt": "Expired title",
            "pt_msg_alt": "Expired message"
        ]
        fields.merge(templateFields) { _, testValue in testValue }
        let jsonData = try JSONSerialization.data(withJSONObject: fields)
        let controller = CTTimerTemplateController()
        controller.data = try XCTUnwrap(String(data: jsonData, encoding: .utf8))
        controller.notificationDeliveryDate = deliveryDate
        return controller
    }

    /// Does what the notification extension does when it shows the template.
    private func show(_ controller: CTTimerTemplateController) {
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 400)
        controller.viewWillAppear(false)
    }

    /// Runs the main run loop, so the countdown timer can fire, until the
    /// condition holds or the timeout passes.
    @discardableResult
    private func runLoop(until condition: () -> Bool, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return condition()
    }

    private func labelTexts(in view: UIView) -> [String] {
        var texts: [String] = []
        if let label = view as? UILabel, let text = label.text {
            texts.append(text)
        }
        for subview in view.subviews {
            texts.append(contentsOf: labelTexts(in: subview))
        }
        return texts
    }

    private func currentTimer(of controller: CTTimerTemplateController) -> Timer? {
        return controller.timer
    }

    // MARK: - Time left at start

    func testThresholdSubtractsTimeSinceDelivery() throws {
        let controller = try makeController(templateFields: ["pt_timer_threshold": "60"],
                                            deliveredAt: Date().addingTimeInterval(-10))
        controller.loadViewIfNeeded()
        XCTAssertTrue((49...50).contains(controller.thresholdSeconds),
                      "60 second threshold delivered 10 seconds ago, got \(controller.thresholdSeconds)")
    }

    func testEndTimeSetsSecondsLeft() throws {
        let endTime = Int(Date().timeIntervalSince1970) + 40
        let controller = try makeController(templateFields: ["pt_timer_end": endTime])
        controller.loadViewIfNeeded()
        XCTAssertTrue((39...40).contains(controller.thresholdSeconds),
                      "end time 40 seconds away, got \(controller.thresholdSeconds)")
    }

    // MARK: - Running and expiring

    func testCountdownTicksOncePerSecond() throws {
        let controller = try makeController(templateFields: ["pt_timer_threshold": "5"])
        show(controller)
        XCTAssertTrue(runLoop(until: { controller.thresholdSeconds < 5 }, timeout: 3))
        XCTAssertEqual(controller.thresholdSeconds, 4)
        XCTAssertTrue(labelTexts(in: controller.view).contains("00:05"))
    }

    func testClockShowsHoursWhenOverAnHour() throws {
        let controller = try makeController(templateFields: ["pt_timer_threshold": "3700"])
        show(controller)
        XCTAssertTrue(runLoop(until: { self.labelTexts(in: controller.view).contains("01:01:40") }, timeout: 3),
                      "label texts: \(labelTexts(in: controller.view))")
    }

    func testExpiryRendersExpiredTextsAndStopsTheTimer() throws {
        let controller = try makeController(templateFields: ["pt_timer_threshold": "1"])
        show(controller)
        XCTAssertTrue(runLoop(until: { self.labelTexts(in: controller.view).contains("Expired title") }, timeout: 5),
                      "label texts: \(labelTexts(in: controller.view))")
        XCTAssertTrue(labelTexts(in: controller.view).contains("Expired message"))
        XCTAssertEqual(currentTimer(of: controller)?.isValid, false)
    }

    func testEndTimeInThePastRendersExpiredStateOnFirstTick() throws {
        let endTime = Int(Date().timeIntervalSince1970) - 60
        let controller = try makeController(templateFields: ["pt_timer_end": endTime])
        show(controller)
        XCTAssertTrue(runLoop(until: { self.labelTexts(in: controller.view).contains("Expired title") }, timeout: 3),
                      "label texts: \(labelTexts(in: controller.view))")
    }

    func testNoTimeSetRendersExpiredState() throws {
        let controller = try makeController(templateFields: [:])
        show(controller)
        XCTAssertTrue(runLoop(until: { self.labelTexts(in: controller.view).contains("Expired title") }, timeout: 3),
                      "label texts: \(labelTexts(in: controller.view))")
    }

    // MARK: - After the notification closes

    /// The bug this guards against: the timer held the controller, so after
    /// the notification closed the countdown kept running and later rendered
    /// the expired state for a view nobody could see.
    func testControllerIsFreedAndTimerStoppedWhenReleasedBeforeExpiry() throws {
        weak var releasedController: CTTimerTemplateController?
        var countdownTimer: Timer?
        try autoreleasepool {
            let controller = try makeController(templateFields: ["pt_timer_threshold": "60"])
            show(controller)
            countdownTimer = currentTimer(of: controller)
            releasedController = controller
        }
        XCTAssertNotNil(countdownTimer)
        XCTAssertTrue(runLoop(until: { releasedController == nil }, timeout: 2),
                      "the controller is still alive after its last reference was dropped")
        XCTAssertEqual(countdownTimer?.isValid, false, "the countdown kept running after the controller was freed")
    }

    func testSecondViewWillAppearKeepsOneTimer() throws {
        let controller = try makeController(templateFields: ["pt_timer_threshold": "60"])
        show(controller)
        let firstTimer = currentTimer(of: controller)
        controller.viewWillAppear(false)
        let secondTimer = currentTimer(of: controller)
        XCTAssertNotNil(firstTimer)
        XCTAssertTrue(firstTimer === secondTimer, "a second timer would count down twice as fast")
        XCTAssertEqual(firstTimer?.isValid, true)
    }
}
