@objc public class CTUtiltiy: NSObject {

    /// How long one image download may take.
    ///
    /// The system stops a notification content extension a few seconds after it
    /// asks the extension to draw. The default request timeout is 60 seconds.
    /// That is longer than the extension is alive. A download that hangs takes
    /// the whole process down. Nothing is drawn and no line is written, because
    /// the completion handler never runs. A shorter timeout turns that case into
    /// an ordinary failure. The failure is logged. The template then draws its
    /// caption only layout.
    private static let imageRequestTimeout: TimeInterval = 10

    static func checkImageUrlValid(imageUrl: String, completionBlock: @escaping (UIImage?) -> Void) -> Void {
        guard !imageUrl.isEmpty else {
            // Not an error. Most templates make some images optional.
            CTContentLog.info("Empty image url, skipping download")
            completionBlock(nil)
            return
        }
        guard let url = URL(string: imageUrl) else {
            CTContentLog.error("Image url parse failed, skipping download, url=\(imageUrl)")
            completionBlock(nil)
            return
        }

        CTContentLog.info("Downloading image, timeout=\(Int(imageRequestTimeout))s, url=\(imageUrl)")
        let startedAt = Date()
        var request = URLRequest(url: url)
        request.timeoutInterval = imageRequestTimeout
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let elapsedMs = Int(Date().timeIntervalSince(startedAt) * 1000)
            if let error = error {
                CTContentLog.error("Image download failed, url=\(imageUrl), elapsedMs=\(elapsedMs), error=\(error.localizedDescription)")
                completionBlock(nil)
                return
            }
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                CTContentLog.error("Image download returned HTTP \(httpResponse.statusCode), url=\(imageUrl), elapsedMs=\(elapsedMs)")
                completionBlock(nil)
                return
            }
            guard let data = data, !data.isEmpty else {
                CTContentLog.error("Image download returned empty body, url=\(imageUrl), elapsedMs=\(elapsedMs)")
                completionBlock(nil)
                return
            }
            guard let imageData = UIImage(data: data) else {
                CTContentLog.error("Image decode failed, url=\(imageUrl), elapsedMs=\(elapsedMs), bytes=\(data.count)")
                completionBlock(nil)
                return
            }

            CTContentLog.info("Image downloaded, url=\(imageUrl), elapsedMs=\(elapsedMs), bytes=\(data.count), size=\(Int(imageData.size.width))x\(Int(imageData.size.height))")
            completionBlock(imageData)
        }
        dataTask.resume()
    }

    static func getCaptionHeight() -> CGFloat {
        return Constraints.kCaptionHeight + Constraints.kSubCaptionHeight + Constraints.kBottomPadding
    }
    
    // Decoding data
    static func loadContentData<T>(data:String)->T? where T:Decodable{
        guard !data.isEmpty else {
            CTContentLog.error("Empty payload, cannot decode \(T.self), template will render its no data layout")
            return nil
        }
        guard let configData = data.data(using: .utf8) else {
            CTContentLog.error("Payload is not valid UTF-8, cannot decode \(T.self)")
            return nil
        }
        do {
            let jsonContent = try JSONDecoder().decode(T.self, from: configData)
            CTContentLog.info("Decoded \(T.self)")
            return jsonContent
        } catch {
            // localizedDescription on a DecodingError only says the data was not valid.
            // String(describing:) names the key that is missing or has the wrong type.
            CTContentLog.error("Decode failed for \(T.self), template will render its no data layout, error=\(String(describing: error))")
            CTContentLog.error("Failed payload=\(data)")
            return nil
        }
    }
    
    // Required keys check for product display template
    @objc public static func isRequiredKeysProvided(jsonString: String)->Bool{
        guard #available(iOS 12.0, *) else {
            CTContentLog.error("Product display requires iOS 12 or later, falling back to basic template")
            return false
        }
        // Every required key is a non optional field on ProductDisplayProperties.
        // A missing key makes the decode fail, so a nil result means a key is
        // missing. loadContentData already logged which key it was.
        guard CTUtiltiy.loadContentData(data: jsonString) as ProductDisplayProperties? != nil else {
            CTContentLog.error("Product display payload missing a required key, falling back to basic template")
            return false
        }
        CTContentLog.info("Product display payload has all required keys")
        return true
    }

    /// One thing a template needs in its payload.
    ///
    /// The rule passes when any key in `keys` is present and not empty. Most
    /// rules hold a single key. A rule holds more than one key when the
    /// template can draw itself from either of them.
    private struct PayloadRequirement {
        let keys: [String]
        /// What the user sees when the rule fails. Support reads this line
        /// next to a screenshot, so it names the visible result.
        let effect: String
    }

    /// What each template needs before it can draw its full layout.
    ///
    /// Only keys whose absence changes what the user sees are listed here.
    /// `pt_title` and `pt_msg` are not listed. The extension falls back to the
    /// title and the body of the notification itself, so a payload without them
    /// still draws text.
    private static func payloadRequirements(for templateId: String) -> [PayloadRequirement] {
        switch templateId {
        case TemplateConstants.kTemplateBasic:
            return [PayloadRequirement(keys: ["pt_big_img", "pt_gif"], effect: "caption only, no image")]
        case TemplateConstants.kTemplateAutoCarousel, TemplateConstants.kTemplateManualCarousel:
            return [PayloadRequirement(keys: ["pt_img1", "pt_img2", "pt_img3"], effect: "caption only, no slides")]
        case TemplateConstants.kTemplateTimer:
            return [PayloadRequirement(keys: ["pt_timer_threshold", "pt_timer_end"], effect: "timer starts at zero, expired state")]
        case TemplateConstants.kTemplateZeroBezel:
            return [PayloadRequirement(keys: ["pt_big_img", "pt_gif"], effect: "caption only, no image")]
        case TemplateConstants.kTemplateWebView:
            return [PayloadRequirement(keys: ["pt_url"], effect: "empty web view")]
        case TemplateConstants.kTemplateRating:
            return [PayloadRequirement(keys: ["pt_big_img", "pt_gif"], effect: "no image above the stars"),
                    PayloadRequirement(keys: ["pt_default_dl"], effect: "a rating tap opens nothing")]
        case TemplateConstants.kTemplateVerticalImage:
            return [PayloadRequirement(keys: ["pt_big_img", "pt_gif"], effect: "texts only, no image")]
        default:
            // Product display is checked by isRequiredKeysProvided. Content
            // slider and single media do not use this payload shape.
            return []
        }
    }

    /// Reports the keys a template needs but did not get.
    ///
    /// The client sends us the payload of a push that drew nothing. This runs
    /// before any drawing and before any download. It names every missing key
    /// in one line, so the reader does not have to read the whole payload.
    /// Nothing here changes what the template draws.
    @objc(logPayloadCheckForTemplate:jsonString:)
    public static func logPayloadCheck(templateId: String, jsonString: String) {
        let requirements = payloadRequirements(for: templateId)
        guard !requirements.isEmpty else { return }

        guard let jsonData = jsonString.data(using: .utf8),
              let payload = (try? JSONSerialization.jsonObject(with: jsonData)) as? [String: Any] else {
            CTContentLog.error("Payload is not a json object, cannot check required keys, template=\(templateId)")
            return
        }

        // Every rule is checked. A short circuit would name only the first
        // missing key. One report should name all of them.
        let unmet = requirements.filter { requirement in
            !requirement.keys.contains { hasValue(payload, $0) }
        }
        guard !unmet.isEmpty else {
            CTContentLog.info("Required keys present, template=\(templateId)")
            return
        }

        let details = unmet.map { requirement -> String in
            let names = requirement.keys.joined(separator: " or ")
            return "\(names) -> \(requirement.effect)"
        }
        CTContentLog.error("Required keys missing, template=\(templateId), missing=[\(details.joined(separator: "; "))]")
    }

    /// True when the payload carries something usable under this key.
    /// A key set to null counts as missing. Text counts only when it is not empty.
    private static func hasValue(_ payload: [String: Any], _ key: String) -> Bool {
        guard let value = payload[key], !(value is NSNull) else {
            return false
        }
        if let text = value as? String {
            return !text.isEmpty
        }
        return true
    }

    //Get controller type between vertical and linear, for product display template
    @objc public static func getControllerType(jsonString: String) -> BaseCTNotificationContentViewController{
        let jsonContent: ProductDisplayProperties? = CTUtiltiy.loadContentData(data: jsonString)
        let isLinear = jsonContent?.pt_product_display_linear?.localizedCaseInsensitiveContains("true") ?? false
        if isLinear {
            CTContentLog.info("Resolved product display layout=linear")
            let contentController = CTProductDisplayLinearViewController()
            contentController.jsonContent = jsonContent
            return contentController
        }
        CTContentLog.info("Resolved product display layout=vertical, pt_product_display_linear=\(jsonContent?.pt_product_display_linear ?? "nil")")
        let contentController = CTProductDisplayVerticalViewController()
        contentController.jsonContent = jsonContent
        return contentController
    }
}
