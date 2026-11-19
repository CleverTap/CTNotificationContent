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
            CTContentLog.debug("Empty image url, skipping download")
            completionBlock(nil)
            return
        }
        guard let url = URL(string: imageUrl) else {
            CTContentLog.error("Image url parse failed, skipping download, url=\(CTContentLog.loggableURL(imageUrl))")
            completionBlock(nil)
            return
        }

        CTContentLog.debug("Downloading image, timeout=\(Int(imageRequestTimeout))s, url=\(imageUrl)")
        let startedAt = Date()
        var request = URLRequest(url: url)
        request.timeoutInterval = imageRequestTimeout
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let elapsedMs = Int(Date().timeIntervalSince(startedAt) * 1000)
            if let error = error {
                CTContentLog.error("Image download failed, url=\(CTContentLog.loggableURL(imageUrl)), elapsedMs=\(elapsedMs), error=\(error.localizedDescription)")
                completionBlock(nil)
                return
            }
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                CTContentLog.error("Image download returned HTTP \(httpResponse.statusCode), url=\(CTContentLog.loggableURL(imageUrl)), elapsedMs=\(elapsedMs)")
                completionBlock(nil)
                return
            }
            guard let data = data, !data.isEmpty else {
                CTContentLog.error("Image download returned empty body, url=\(CTContentLog.loggableURL(imageUrl)), elapsedMs=\(elapsedMs)")
                completionBlock(nil)
                return
            }
            guard let imageData = UIImage(data: data) else {
                CTContentLog.error("Image decode failed, url=\(CTContentLog.loggableURL(imageUrl)), elapsedMs=\(elapsedMs), bytes=\(data.count)")
                completionBlock(nil)
                return
            }

            CTContentLog.debug("Image downloaded, url=\(imageUrl), elapsedMs=\(elapsedMs), bytes=\(data.count), size=\(Int(imageData.size.width))x\(Int(imageData.size.height))")
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
            CTContentLog.debug("Decoded \(T.self)")
            return jsonContent
        } catch {
            CTContentLog.error("Decode failed for \(T.self), template will render its no data layout, error=\(String(describing: error))")
            CTContentLog.debug("Failed payload=\(data)")
            return nil
        }
    }

    // Required keys check for product display template
    @objc public static func isRequiredKeysProvided(jsonString: String)->Bool{
        guard CTUtiltiy.loadContentData(data: jsonString) as ProductDisplayProperties? != nil else {
            CTContentLog.error("Product display payload missing a required key, falling back to basic template")
            return false
        }
        CTContentLog.debug("Product display payload has all required keys")
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
