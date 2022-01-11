import UIKit

class CTCaptionImageView: UIViewController {
    var myData: String = ""
    var myurls = [URL]()
    var captionarray = [String]()
    var subcaptionarray = [String]()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var subcaption: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        get_records(myData: myData)
        set_text();
    }
    func get_records(myData:String){
      let data = myData.data(using: .utf8)
        
        do{
        let contentslider = try JSONDecoder().decode(ContentSlider.self,from: data!)
            for slides in contentslider.items{
                myurls.append(URL(string: slides.imageUrl)!)
                captionarray.append(slides.caption)
                subcaptionarray.append(slides.subcaption)
            }
//            self.orientation = contentslider.orientation
            
            
        } catch {
                print(error)
            }
 
    }
    func set_text() {
        caption.text = captionarray[1]
        subcaption.text = subcaptionarray[1]
    }
    func loadImage() {
    let imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg")!
    imageView.sd_setImage(with: imageURL)
        }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    public init() {
        super.init(nibName: "CTCaptionImageView", bundle: Bundle(for: CTCaptionImageView.self))
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
