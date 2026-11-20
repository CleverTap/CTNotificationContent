import XCTest
import UIKit
import SDWebImage
@testable import CTNotificationContent

/// Tests for the zero bezel template's text colours with and without an image.
///
/// Its default text is white, made for text on top of the image. Without an
/// image the text sits on the notification's own background, so in light
/// mode it needs dark text to stay readable.
final class CTZeroBezelControllerTests: XCTestCase {

    private var temporaryFiles: [URL] = []

    override func tearDown() {
        for fileURL in temporaryFiles {
            try? FileManager.default.removeItem(at: fileURL)
        }
        temporaryFiles = []
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeController(templateFields: [String: Any],
                                style: UIUserInterfaceStyle) throws -> CTZeroBezelController {
        var fields: [String: Any] = ["pt_title": "Zero bezel title", "pt_msg": "Zero bezel message"]
        fields.merge(templateFields) { _, testValue in testValue }
        let jsonData = try JSONSerialization.data(withJSONObject: fields)
        let controller = CTZeroBezelController()
        controller.data = try XCTUnwrap(String(data: jsonData, encoding: .utf8))
        controller.overrideUserInterfaceStyle = style
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        return controller
    }

    private func label(withText text: String, in view: UIView) -> UILabel? {
        if let label = view as? UILabel,
           label.text?.trimmingCharacters(in: .whitespacesAndNewlines) == text {
            return label
        }
        for subview in view.subviews {
            if let found = label(withText: text, in: subview) {
                return found
            }
        }
        return nil
    }

    /// The colour the label draws its text in. setTextColor puts it on the
    /// attributed text, so that is read first.
    private func shownColor(of label: UILabel?) -> UIColor? {
        guard let label = label else { return nil }
        if let attributed = label.attributedText, attributed.length > 0,
           let color = attributed.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor {
            return color
        }
        return label.textColor
    }

    private func titleColor(of controller: CTZeroBezelController) -> UIColor? {
        return shownColor(of: label(withText: "Zero bezel title", in: controller.view))
    }

    private func messageColor(of controller: CTZeroBezelController) -> UIColor? {
        return shownColor(of: label(withText: "Zero bezel message", in: controller.view))
    }

    /// The fade behind the text is the view that draws a gradient, either as
    /// its own layer or as a sublayer that belongs to no subview.
    private func fadeView(in view: UIView) -> UIView? {
        if view.layer is CAGradientLayer {
            return view
        }
        let subviewLayers = view.subviews.map { $0.layer }
        let ownsGradientSublayer = view.layer.sublayers?.contains(where: { sublayer in
            sublayer is CAGradientLayer && !subviewLayers.contains(where: { $0 === sublayer })
        }) ?? false
        if ownsGradientSublayer {
            return view
        }
        for subview in view.subviews {
            if let found = fadeView(in: subview) {
                return found
            }
        }
        return nil
    }

    /// The rectangle the fade's gradient is drawn in, in the fade view's own
    /// coordinates.
    private func gradientFrame(in fadeView: UIView) -> CGRect? {
        if fadeView.layer is CAGradientLayer {
            return fadeView.layer.bounds
        }
        return fadeView.layer.sublayers?.first(where: { $0 is CAGradientLayer })?.frame
    }

    private func makeImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 30))
        return renderer.image { context in
            UIColor.systemTeal.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 40, height: 30))
        }
    }

    /// A small image on disk, so the image path runs without the network.
    private func makeImageFile() throws -> String {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("zero_bezel_\(UUID().uuidString).png")
        try XCTUnwrap(makeImage().pngData()).write(to: fileURL)
        temporaryFiles.append(fileURL)
        return fileURL.absoluteString
    }

    @discardableResult
    private func runLoop(until condition: () -> Bool, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return condition()
    }

    // MARK: - Tests

    func testNoImageInLightModeUsesDarkText() throws {
        let controller = try makeController(templateFields: [:], style: .light)

        XCTAssertEqual(titleColor(of: controller), UIColor(hex: ConstantKeys.kHexBlackColor))
        XCTAssertEqual(messageColor(of: controller), UIColor(hex: ConstantKeys.kHexLightGrayColor))
        XCTAssertEqual(fadeView(in: controller.view)?.isHidden, true)
    }

    func testNoImageInDarkModeKeepsWhiteText() throws {
        let controller = try makeController(templateFields: [:], style: .dark)

        XCTAssertEqual(titleColor(of: controller), UIColor(hex: ConstantKeys.kHexWhiteColor))
        XCTAssertEqual(messageColor(of: controller), UIColor(hex: ConstantKeys.kHexWhiteColor))
    }

    func testNoImageKeepsColoursThePayloadSet() throws {
        let controller = try makeController(templateFields: ["pt_title_clr": "#0000FF"], style: .light)

        XCTAssertEqual(titleColor(of: controller), UIColor(hex: "#0000FF"))
        // The message colour was left out, so it still gets the readable default.
        XCTAssertEqual(messageColor(of: controller), UIColor(hex: ConstantKeys.kHexLightGrayColor))
    }

    func testImageSwitchesToWhiteTextOverTheFade() throws {
        let controller = try makeController(templateFields: ["pt_big_img": try makeImageFile()], style: .light)
        let white = UIColor(hex: ConstantKeys.kHexWhiteColor)

        XCTAssertTrue(runLoop(until: { self.titleColor(of: controller) == white }, timeout: 5))
        XCTAssertEqual(messageColor(of: controller), white)
        XCTAssertEqual(fadeView(in: controller.view)?.isHidden, false)
    }

    func testFadeCoversItsAreaWhenTheGifComesFromTheCache() throws {
        // A gif already in the memory cache arrives while the view is still
        // being built, before the first layout pass.
        let gifURL = "https://cached.invalid/zero_bezel_\(UUID().uuidString).gif"
        SDImageCache.shared.store(makeImage(), forKey: gifURL, toDisk: false, completion: nil)
        let controller = try makeController(templateFields: ["pt_gif": gifURL], style: .light)
        controller.view.layoutIfNeeded()

        let fade = try XCTUnwrap(fadeView(in: controller.view))
        XCTAssertFalse(fade.isHidden)
        XCTAssertGreaterThan(fade.bounds.height, CTUtiltiy.getCaptionHeight() * 0.3)
        let gradient = try XCTUnwrap(gradientFrame(in: fade))
        XCTAssertEqual(gradient.height, fade.bounds.height, accuracy: 0.5)
        XCTAssertEqual(gradient.width, fade.bounds.width, accuracy: 0.5)
    }

    func testInvalidColoursFallBackToTheTemplateDefaults() throws {
        let invalidColours: [String: Any] = [
            "pt_title_clr": "notacolor", "pt_msg_clr": "#GGGGGG",
            "pt_title_clr_dark": "nope", "pt_msg_clr_dark": "#12"
        ]
        let white = UIColor(hex: ConstantKeys.kHexWhiteColor)

        let lightWithoutImage = try makeController(templateFields: invalidColours, style: .light)
        XCTAssertEqual(titleColor(of: lightWithoutImage), UIColor(hex: ConstantKeys.kHexBlackColor))
        XCTAssertEqual(messageColor(of: lightWithoutImage), UIColor(hex: ConstantKeys.kHexLightGrayColor))

        let darkWithoutImage = try makeController(templateFields: invalidColours, style: .dark)
        XCTAssertEqual(titleColor(of: darkWithoutImage), white)
        XCTAssertEqual(messageColor(of: darkWithoutImage), white)

        var withImage = invalidColours
        withImage["pt_big_img"] = try makeImageFile()
        let lightWithImage = try makeController(templateFields: withImage, style: .light)
        XCTAssertTrue(runLoop(until: { self.fadeView(in: lightWithImage.view)?.isHidden == false }, timeout: 5))
        XCTAssertEqual(titleColor(of: lightWithImage), white)
        XCTAssertEqual(messageColor(of: lightWithImage), white)
    }
}
