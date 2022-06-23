class CTUtiltiy {
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
    
    static func getCaptionHeight() -> CGFloat {
        return Constraints.kCaptionHeight + Constraints.kSubCaptionHeight + Constraints.kBottomPadding
    }
}
