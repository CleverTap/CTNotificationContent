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
        let label = UILabel(frame: CGRect(x: x, y: y, width: UIScreen.main.bounds.width, height: height))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = captions[selectedIndex]
        label.textAlignment = .center
        addSubview(label)
        let subcaptionLabel = UILabel(frame: CGRect(x: x, y: y, width: UIScreen.main.bounds.width, height: subcaptionheight))
        subcaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        subcaptionLabel.text = subcaptions[selectedIndex]
        addSubview(subcaptionLabel)
        NSLayoutConstraint.activate([
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: label.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: subcaptionLabel.topAnchor),
            subcaptionLabel.topAnchor.constraint(equalTo: label.bottomAnchor),
            subcaptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subcaptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subcaptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
                
        ])
        
        scheduleTimerIfNeeded()
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
