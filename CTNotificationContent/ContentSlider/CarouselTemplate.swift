import UIKit

class CarouselTemplate: UIViewController {
    var myData: String = ""
    var myurls = [URL]()
    var captionarray = [String]()
    var subcaptionarray = [String]()
    lazy var carousel = Carousel(frame: .zero, urls: myurls, captions: captionarray, subcaptions: subcaptionarray)
    public func get_records(myData:String){
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
    override func viewDidLoad() {
        super.viewDidLoad()
        get_records(myData: myData)
        setupHierarchy()
        setupComponents()
        setupConstraints()
        // Do any additional setup after loading the view.
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        self.view = view
    }
    
    func setupHierarchy() {
        self.view.addSubview(carousel)
    }
    
    func setupComponents() {
        carousel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            carousel.topAnchor.constraint(equalTo: view.topAnchor),
            carousel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

