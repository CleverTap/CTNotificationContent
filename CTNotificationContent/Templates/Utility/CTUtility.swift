@objc public class CTUtiltiy: NSObject {
    static func checkImageUrlValid(imageUrl: String, completionBlock: @escaping (UIImage?) -> Void) -> Void {
        if let url = URL(string: imageUrl) {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    // Invalid url or error in loading url.
                    completionBlock(nil)
                    return
                }
                guard let imageData = UIImage(data: data) else {
                    // Image can't be loaded from url.
                    completionBlock(nil)
                    return
                }
                
                // Image url is valid.
                completionBlock(imageData)
            }
            dataTask.resume()
        } else {
            // Image url is empty.
            completionBlock(nil)
        }
    }
    
    static func webViewURLReachable(webViewURL: String, completion: @escaping (Bool) -> ()) {
        if let url = URL(string: webViewURL){
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            URLSession.shared.dataTask(with: request) { _, response, _ in
                completion((response as? HTTPURLResponse)?.statusCode == 200)
            }.resume()
        }
    }
    
    static func getCaptionHeight() -> CGFloat {
        return Constraints.kCaptionHeight + Constraints.kSubCaptionHeight + Constraints.kBottomPadding
    }
    
    // Decoding data
    static func loadContentData<T>(data:String)->T? where T:Decodable{
        var jsonContent: T? = nil
        if let configData = data.data(using: .utf8) {
            do {
                jsonContent = try JSONDecoder().decode(T.self, from: configData)
            } catch let error {
                print("Failed to load: \(error.localizedDescription)")
                jsonContent = nil
            }
        }
        return jsonContent
    }
    
    // Required keys check for product display template
    @objc public static func isRequiredKeysProvided(jsonString: String)->Bool{
        if #available(iOS 12.0, *) {
            let jsonContent: ProductDisplayProperties? = CTUtiltiy.loadContentData(data: jsonString)
            if ( jsonContent?.pt_img1 == nil || jsonContent?.pt_img2 == nil || jsonContent?.pt_bt1 == nil || jsonContent?.pt_bt2 == nil || jsonContent?.pt_st1 == nil || jsonContent?.pt_st2 == nil || jsonContent?.pt_dl1 == nil || jsonContent?.pt_dl2 == nil || jsonContent?.pt_price1 == nil || jsonContent?.pt_price2 == nil || jsonContent?.pt_product_display_action == nil){
                return false
            }else{
                return true
            }
        }else{
            return false
        }        
    }
    
    /// Applies pt_img_corner_radius and pt_img_border_width/clr to any UIView
    /// whose layer supports these properties (UIImageView, SDAnimatedImageView).
    /// Absent/zero values produce no layer change - legacy render path is untouched.
    static func applyImageStyling(
        to view: UIView,
        cornerRadius: CGFloat,
        borderWidth: CGFloat,
        borderClr: String?
    ) {
        let clampedRadius = min(max(cornerRadius, 0), Constraints.kImageCornerRadiusMax)
        let clampedWidth = min(max(borderWidth, 0), Constraints.kImageBorderWidthMax)

        if clampedRadius > 0 {
            view.layer.cornerRadius = clampedRadius
            view.clipsToBounds = true
        }

        if clampedWidth > 0 {
            view.layer.borderWidth = clampedWidth
            view.clipsToBounds = true
            let hex = (borderClr != nil && !borderClr!.isEmpty) ? borderClr! : "#00000000"
            if let color = UIColor(hex: hex) {
                view.layer.borderColor = color.cgColor
            }
        }
    }

    //Get controller type between vertical and linear, for product display template
    @objc public static func getControllerType(jsonString: String) -> BaseCTNotificationContentViewController{
        let jsonContent: ProductDisplayProperties? = CTUtiltiy.loadContentData(data: jsonString)
        if (jsonContent?.pt_product_display_linear != nil){
                if
                    ((jsonContent?.pt_product_display_linear?.localizedCaseInsensitiveContains("true"))!) {
                let contentController: CTProductDisplayLinearViewController = CTProductDisplayLinearViewController()
//                    contentController.data = jsonString
                    contentController.jsonContent = jsonContent
                    return contentController
                }else{
                    let contentController: CTProductDisplayVerticalViewController =
                    CTProductDisplayVerticalViewController()
//                    contentController.data = jsonString
                    contentController.jsonContent = jsonContent
                    return contentController
                }
        }else{
            let contentController: CTProductDisplayVerticalViewController = CTProductDisplayVerticalViewController()
//                contentController.data = jsonString
            contentController.jsonContent = jsonContent
            return contentController
        }
    }
}
