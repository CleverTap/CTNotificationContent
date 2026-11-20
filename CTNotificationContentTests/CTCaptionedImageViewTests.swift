import XCTest
import UIKit
import SDWebImage
@testable import CTNotificationContent

/// Tests for what the captioned image view shows when its gif fails. The basic
/// and carousel templates build their slides from this view.
///
/// The caption, subcaption and colours are set while the view is built. The
/// gif arrives later in a download callback, and a failed download returns
/// from that callback without touching them.
final class CTCaptionedImageViewTests: XCTestCase {

    private var temporaryFiles: [URL] = []

    override func tearDown() {
        for fileURL in temporaryFiles {
            try? FileManager.default.removeItem(at: fileURL)
        }
        temporaryFiles = []
        CTContentLog.setDebugLevel(-1)
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeComponents(imageUrl: String) -> CaptionedImageViewComponents {
        var components = CaptionedImageViewComponents()
        components.caption = "Gif caption"
        components.subcaption = "Gif subcaption"
        components.imageUrl = imageUrl
        components.bgColor = "#FFF3D6"
        components.captionColor = "#8B0000"
        components.subcaptionColor = "#1F3A93"
        components.bgColorDark = "#12355B"
        components.captionColorDark = "#FFD60A"
        components.subcaptionColorDark = "#7CFC00"
        return components
    }

    private func makeView(imageUrl: String) -> CTCaptionedImageView {
        let view = CTCaptionedImageView(components: makeComponents(imageUrl: imageUrl), isGifSupported: true)
        view.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        view.overrideUserInterfaceStyle = .light
        return view
    }

    private func labels(in view: UIView) -> [UILabel] {
        return view.subviews.compactMap { $0 as? UILabel }
    }

    private func imageView(in view: UIView) throws -> UIImageView {
        return try XCTUnwrap(view.subviews.compactMap { $0 as? UIImageView }.first)
    }

    private func assertCaptionShown(in view: CTCaptionedImageView,
                                    file: StaticString = #filePath, line: UInt = #line) throws {
        let shownLabels = labels(in: view)
        XCTAssertEqual(shownLabels.count, 2, file: file, line: line)
        XCTAssertEqual(shownLabels.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), "Gif caption", file: file, line: line)
        XCTAssertEqual(shownLabels.last?.text?.trimmingCharacters(in: .whitespacesAndNewlines), "Gif subcaption", file: file, line: line)
        XCTAssertEqual(shownLabels.first?.textColor, UIColor(hex: "#8B0000"), file: file, line: line)
        XCTAssertEqual(shownLabels.last?.textColor, UIColor(hex: "#1F3A93"), file: file, line: line)
        XCTAssertEqual(try imageView(in: view).backgroundColor, UIColor(hex: "#FFF3D6"), file: file, line: line)
    }

    /// Runs the main run loop, so a download callback can arrive, until the
    /// condition holds or the timeout passes.
    @discardableResult
    private func runLoop(until condition: () -> Bool, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return condition()
    }

    // MARK: - Tests

    func testUnparseableGifUrlStillShowsCaptionAndColours() throws {
        // "http://[::1" is a url Foundation cannot parse, so no download starts.
        let view = makeView(imageUrl: "http://[::1")

        try assertCaptionShown(in: view)
        XCTAssertNil(try imageView(in: view).image)
    }

    func testGifThatFailsToLoadStillShowsCaptionAndColours() throws {
        // Level 0, so the failure line is written as an app with logs on
        // would see it.
        CTContentLog.setDebugLevel(0)

        // A local file that is not an image, so the download fails without
        // needing the network.
        let notAnImage = FileManager.default.temporaryDirectory
            .appendingPathComponent("not_a_gif_\(UUID().uuidString).gif")
        try Data("this is not a gif".utf8).write(to: notAnImage)
        temporaryFiles.append(notAnImage)

        let view = makeView(imageUrl: notAnImage.absoluteString)
        try assertCaptionShown(in: view)

        // Wait for the download to finish, then give its callback a moment on
        // the main queue, and check nothing the user sees has changed.
        let downloader = SDWebImageDownloader.shared
        XCTAssertTrue(runLoop(until: { downloader.currentDownloadCount == 0 }, timeout: 5))
        runLoop(until: { false }, timeout: 0.5)
        try assertCaptionShown(in: view)
        XCTAssertNil(try imageView(in: view).image)
    }
}
