struct FlexibleDouble: Decodable {
    let value: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = Double(intVal)
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let strVal = try? container.decode(String.self), let parsed = Double(strVal) {
            value = parsed
        } else {
            throw DecodingError.typeMismatch(
                Double.self,
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Expected Int, Double, or numeric String")
            )
        }
    }
}

@objc public class CTUtiltiy: NSObject {

    private static let imageRequestTimeout: TimeInterval = 10

    static func checkImageUrlValid(imageUrl: String, completionBlock: @escaping (UIImage?) -> Void) -> Void {
        guard !imageUrl.isEmpty else {
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
            CTContentLog.error("Decode failed for \(T.self), template will render its no data layout, error=\(String(describing: error))")
            CTContentLog.debug("Failed payload=\(data)")
            return nil
        }
    }

    // Required keys check for product display template
    @objc public static func isRequiredKeysProvided(jsonString: String)->Bool{
        guard #available(iOS 12.0, *) else {
            CTContentLog.error("Product display requires iOS 12 or later, falling back to basic template")
            return false
        }
        guard CTUtiltiy.loadContentData(data: jsonString) as ProductDisplayProperties? != nil else {
            CTContentLog.error("Product display payload missing a required key, falling back to basic template")
            return false
        }
        CTContentLog.info("Product display payload has all required keys")
        return true
    }

    static func resolveCornerRadius(_ value: CGFloat, rootHeight: CGFloat) -> CGFloat {
        guard value > 0, rootHeight > 0 else { return 0 }
        return rootHeight * value / 100.0
    }

    static func resolveBorderWidth(_ value: CGFloat, rootHeight: CGFloat) -> CGFloat {
        guard value > 0, rootHeight > 0 else { return 0 }
        return max(1, rootHeight * value / 1000.0)
    }

    static func applyImageStyling(
        to view: UIView,
        cornerRadius: CGFloat,
        borderWidth: CGFloat,
        borderClr: String,
        imageHeight: CGFloat,
        rootHeight: CGFloat
    ) {
        let resolvedRadius = resolveCornerRadius(cornerRadius, rootHeight: imageHeight)
        let resolvedWidth = resolveBorderWidth(borderWidth, rootHeight: rootHeight)

        if resolvedRadius > 0 {
            view.layer.cornerRadius = resolvedRadius
            view.clipsToBounds = true
        }

        if resolvedWidth > 0 {
            view.layer.borderWidth = resolvedWidth
            view.clipsToBounds = true
            if let color = UIColor(hex: borderClr) {
                view.layer.borderColor = color.cgColor
            }
        }
    }

    private struct PayloadRequirement {
        let keys: [String]
        let effect: String
        var minimum: Int = 1
    }

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
        case TemplateConstants.kTemplateFiveIcons:
            return [PayloadRequirement(keys: ["pt_img1", "pt_img2", "pt_img3", "pt_img4", "pt_img5"],
                                       effect: "caption only, no icons",
                                       minimum: Constraints.kFiveIconsMinIcons)]
        default:
            return []
        }
    }

    @objc(logPayloadCheckForTemplate:jsonString:)
    public static func logPayloadCheck(templateId: String, jsonString: String) {
        let requirements = payloadRequirements(for: templateId)
        guard !requirements.isEmpty else {
            CTContentLog.info("No required key rules for template=\(templateId), skipping payload check")
            return
        }

        guard let jsonData = jsonString.data(using: .utf8),
              let payload = (try? JSONSerialization.jsonObject(with: jsonData)) as? [String: Any] else {
            CTContentLog.error("Payload is not a json object, cannot check required keys, template=\(templateId)")
            return
        }

        let unmet = requirements.filter { requirement in
            requirement.keys.filter { hasValue(payload, $0) }.count < requirement.minimum
        }
        guard !unmet.isEmpty else {
            CTContentLog.info("Required keys present, template=\(templateId)")
            return
        }

        let details = unmet.map { requirement -> String in
            if requirement.minimum > 1 {
                let present = requirement.keys.filter { hasValue(payload, $0) }.count
                let names = requirement.keys.joined(separator: ", ")
                return "at least \(requirement.minimum) of \(names), got \(present) -> \(requirement.effect)"
            }
            let names = requirement.keys.joined(separator: " or ")
            return "\(names) -> \(requirement.effect)"
        }
        CTContentLog.error("Required keys missing, template=\(templateId), missing=[\(details.joined(separator: "; "))]")
    }

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
