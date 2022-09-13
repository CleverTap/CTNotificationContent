import UIKit
import WebKit

@objc public class CTWebViewController: BaseCTNotificationContentViewController, WKNavigationDelegate {

    var contentView: UIView = UIView(frame: .zero)
    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""
    var jsonContent: WebViewProperties? = nil
    var templateDl1:String = ""
    var heightConstant:CGFloat = 0
    var webView : WKWebView!
    var webViewUrl: String = ""
    var pageReachable: Bool = false
            
    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        titleLabel.textColor = UIColor.black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    private var subTitleLabel: UILabel = {
        let subTitleLabel = UILabel()
        subTitleLabel.textAlignment = .left
        subTitleLabel.adjustsFontSizeToFitWidth = false
        subTitleLabel.font = UIFont.systemFont(ofSize: 12.0)
        subTitleLabel.textColor = UIColor.lightGray
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return subTitleLabel
    }()
            
    @objc public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)
        jsonContent = CTUtiltiy.loadContentData(data: data)
        createView()
        setupConstraints()
    }

    func createFrameWithoutWebView() {
        let viewWidth = view.frame.size.width
        let viewHeight = CTUtiltiy.getCaptionHeight()
        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }
    
    func createFrameWithWebView() {
        let viewWidth = view.frame.size.width
        var viewHeight = viewWidth + CTUtiltiy.getCaptionHeight()
        // For view in Landscape
        viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + CTUtiltiy.getCaptionHeight()
        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }

    func createView() {
        let webViewURL = jsonContent?.pt_url
        titleLabel.isHidden = true
        subTitleLabel.isHidden = true
        CTUtiltiy.webViewURLReachable(webViewURL: webViewURL!) { success in
        DispatchQueue.main.async {
            if success {
                self.createFrameWithWebView()
                
            } else {
                self.webView.isHidden = true
                self.titleLabel.isHidden = false
                self.subTitleLabel.isHidden = false
                self.createFrameWithoutWebView()
            }
        }
    }
        if let payloadURL = jsonContent?.pt_url, !payloadURL.isEmpty {
            webViewUrl = payloadURL
        }
        else {
            titleLabel.isHidden = false
            subTitleLabel.isHidden = false
            createFrameWithoutWebView()
        }
        let url = NSURL(string: webViewUrl)
        let request = NSURLRequest(url: url! as URL)
        // init and load request in webview.
        webView = WKWebView(frame: contentView.frame)
        webView.navigationDelegate = self
        webView.load(request as URLRequest)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(webView)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(titleLabel)
        activateImageViewContraints()
        
        guard let jsonContent = jsonContent else {
            return
        }
        if let title = jsonContent.pt_title, !title.isEmpty{
            templateCaption = title
        }
        if let msg = jsonContent.pt_msg, !msg.isEmpty{
            templateSubcaption = msg
        }
        if let msgSummary = jsonContent.pt_msg_summary, !msgSummary.isEmpty{
            templateSubcaption = msgSummary
        }
        if let deeplink = jsonContent.pt_dl1, !deeplink.isEmpty{
            deeplinkURL = deeplink
        }
        self.titleLabel.text = templateCaption
        self.subTitleLabel.text = templateSubcaption
        
        if let titleColor = jsonContent.pt_title_clr {
            self.titleLabel.textColor = UIColor(hex: titleColor)
        }
        if let msgColor = jsonContent.pt_msg_clr {
            self.subTitleLabel.textColor = UIColor(hex: msgColor)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(CTUtiltiy.getCaptionHeight() - Constraints.kCaptionTopPadding)),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            titleLabel.heightAnchor.constraint(equalToConstant: Constraints.kCaptionHeight),
            
            subTitleLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(Constraints.kSubCaptionHeight + Constraints.kSubCaptionTopPadding)),
            subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            subTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constraints.kSubCaptionTopPadding),
            subTitleLabel.heightAnchor.constraint(equalToConstant: Constraints.kSubCaptionHeight)])
    }

    func activateImageViewContraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    @objc public override func handleAction(_ action: String) -> UNNotificationContentExtensionResponseOption {
        if action == ConstantKeys.kAction3 {
            // Maps to run the relevant deeplink
            if !deeplinkURL.isEmpty {
                if let url = URL(string: deeplinkURL) {
                    getParentViewController().open(url)
                }
            }
            return .dismiss
        }
        return .doNotDismiss
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

//MARK:- WKNavigationDelegate

    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.localizedDescription)
    }
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
    }
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("finish to load")
    }
