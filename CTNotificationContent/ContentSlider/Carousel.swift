import UIKit
import SDWebImage

class Carousel: UIView {
//    let label = UILabel(frame: CGRect(x: x, y: y, width: UIScreen.main.bounds.width, height: height))
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: CarouselLayout()
    )
    
    var urls: [URL] = []
    var captions: [String] = []
    var subcaptions: [String] = []
    var selectedIndex: Int = 0
    var currentText: String = ""
    var pageControl: UIPageControl?
    var captionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: GenericConstants.Size.captionHeight))
    var subcaptionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: GenericConstants.Size.subCaptionHeight))

    private var timer: Timer?
    
    public init(frame: CGRect, urls: [URL], captions: [String], subcaptions: [String]) {
        self.urls = urls
        self.captions = captions
        self.subcaptions = subcaptions
        super.init(frame: frame)
        setupView()
    }
    
    // init from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    // init from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    let x: CGFloat = 0
    let y: CGFloat = 0
    let height: CGFloat = 50
    let subcaptionheight: CGFloat = 20
    private func setupView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = false
        collectionView.isPagingEnabled = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        let leftPadding = GenericConstants.Size.captionLeftPadding
        let bottomPadding = GenericConstants.Size.subCaptionBottomPadding
        
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.text = captions[selectedIndex]
        captionLabel.textAlignment = .left
        addSubview(captionLabel)
        
        subcaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        subcaptionLabel.text = subcaptions[selectedIndex]
        subcaptionLabel.textAlignment = .left
        addSubview(subcaptionLabel)
        
        showPagingControl()

        
        NSLayoutConstraint.activate([
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            captionLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: GenericConstants.Size.captionTopPadding),
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftPadding),
            captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -leftPadding),
            
            subcaptionLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: GenericConstants.Size.subCaptionTopPadding),
            subcaptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftPadding),
            subcaptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -leftPadding),
            subcaptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomPadding)
        ])
        
        if let pageControl = pageControl {
            let centerHorizontally = NSLayoutConstraint(item: pageControl,
                                                        attribute: .centerX,
                                                        relatedBy: .equal,
                                                        toItem: collectionView,
                                                        attribute: .centerX,
                                                        multiplier: 1.0,
                                                        constant: 0.0)
            
            NSLayoutConstraint.activate([centerHorizontally,
                                         pageControl.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -GenericConstants.Size.pageControlBottomPadding)])
        }
        scheduleTimerIfNeeded()
    }
    
    private func showPagingControl() {
        if let _ = pageControl {
            return
        }
        pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: GenericConstants.Size.pageControlViewHeight))
        pageControl?.numberOfPages = captions.count
        pageControl?.hidesForSinglePage = true
        pageControl?.translatesAutoresizingMaskIntoConstraints = false
        
        if let pageControl = pageControl {
            addSubview(pageControl)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func scheduleTimerIfNeeded() {
        guard urls.count > 1 else { return }
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 1.5,
            repeats: true,
            block: { [weak self] _ in
                self?.selectNext()
            }
        )
    }
    
    private func selectNext() {
        selectItem(at: selectedIndex + 1)
    }
    
    private func selectItem(at index: Int) {
        let index = urls.count > index ? index : 0
        guard selectedIndex != index else { return }
        selectedIndex = index
        collectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        
        //Update UI
        pageControl?.currentPage = selectedIndex
        captionLabel.text = captions[selectedIndex]
        subcaptionLabel.text = subcaptions[selectedIndex]
    }
}

extension Carousel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView: UIImageView = UIImageView(frame: .zero )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.sd_setImage(with: urls[indexPath.row], placeholderImage: UIImage(named: "placeholder"))
        cell.contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cell.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor)
        ])
        return cell
    }
}

extension Carousel: UICollectionViewDelegate {}
