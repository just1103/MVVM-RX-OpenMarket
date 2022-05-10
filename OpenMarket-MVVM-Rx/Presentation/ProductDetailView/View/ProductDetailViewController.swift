import UIKit
import RxSwift
import RxCocoa

class ProductDetailViewController: UIViewController {
    // MARK: - Nested Types
    enum Design {
        static let bgcolor = #colorLiteral(red: 0.9524367452, green: 0.9455882907, blue: 0.9387311935, alpha: 1)
        static let lightGreenColor = #colorLiteral(red: 0.5567998886, green: 0.7133290172, blue: 0.6062341332, alpha: 1)
        static let darkGreenColor = #colorLiteral(red: 0.137904644, green: 0.3246459067, blue: 0.2771841288, alpha: 1)
        static let veryDarkGreenColor = #colorLiteral(red: 0.04371468723, green: 0.1676974297, blue: 0.1483464539, alpha: 1)
        static let nameLabelFont: UIFont = .preferredFont(forTextStyle: .title3)
        static let stockLabelFont: UIFont = .preferredFont(forTextStyle: .title3)
        static let stockLabelTextColor: UIColor = .systemOrange
        static let accessoryImageName: String = "chevron.right"
        static let priceLabelFont: UIFont = .preferredFont(forTextStyle: .headline)
        static let priceLabelTextColor: UIColor = .systemRed
        static let bargainRateLabelFont: UIFont = .preferredFont(forTextStyle: .body)
        static let bargainRateLabelTextColor: UIColor = .systemRed
    }
    
    // MARK: - Properties
    // TODO: Custom StackView 타입 생성하여 코드 분리할지 고려
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let imageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let imagePageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = .systemGray6
        pageControl.currentPageIndicatorTintColor = Design.darkGreenColor
        pageControl.currentPage = 0
        // TODO: 메서드로 pageCount 설정
        return pageControl
    }()
    
    private let productInformationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Design.nameLabelFont
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let priceAndStockStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let priceContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private let priceAndBargainpriceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Design.priceLabelFont
        label.textColor = Design.priceLabelTextColor
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let bargainPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Design.priceLabelFont
        label.textColor = Design.priceLabelTextColor
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private let bargainRateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = Design.bargainRateLabelFont
        label.textColor = Design.bargainRateLabelTextColor
        return label
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = Design.stockLabelFont
        label.textColor = Design.stockLabelTextColor
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = Design.bargainRateLabelFont
        label.textColor = Design.bargainRateLabelTextColor
        return label
    }()
    
    private var viewModel: ProductDetailViewModel!
    
    // MARK: - Initializers
    convenience init(viewModel: ProductDetailViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Methods
    //    func apply(data: Product) {
    ////        imageView.loadImage(of: data.thumbnail)
    //        nameLabel.text = data.name
    //        changePriceAndDiscountedPriceLabel(price: data.price,
    //                                           discountedPrice: data.discountedPrice,
    //                                           bargainPrice: data.bargainPrice,
    //                                           currency: data.currency)
    //        changeStockLabel(by: data.stock)
    //        calculateBargainRate(price: data.price, discountedPrice: data.discountedPrice)
    //    }
    
    private func configureUI() {
        view.addSubview(containerStackView)
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        containerStackView.addArrangedSubview(imageCollectionView)
        containerStackView.addArrangedSubview(imagePageControl)
        containerStackView.addArrangedSubview(productInformationStackView)
        containerStackView.addArrangedSubview(descriptionLabel)
        
        productInformationStackView.addArrangedSubview(nameLabel)
        productInformationStackView.addArrangedSubview(priceContainerStackView)
        productInformationStackView.addArrangedSubview(stockLabel)
        
        priceContainerStackView.addArrangedSubview(priceAndBargainpriceStackView)
        priceContainerStackView.addArrangedSubview(bargainRateLabel)
        
        priceAndBargainpriceStackView.addArrangedSubview(bargainPriceLabel)
        priceAndBargainpriceStackView.addArrangedSubview(priceLabel)
    }
    
    private func changePriceAndDiscountedPriceLabel(price: Double,
                                                    discountedPrice: Double,
                                                    bargainPrice: Double,
                                                    currency: Currency) {
        if discountedPrice == 0 {
            priceLabel.text = "\(currency.rawValue) \(price.formattedWithComma())"
        } else {
            let priceText = "\(currency.rawValue) \(price.formattedWithComma())"
            priceLabel.strikeThrough(text: priceText)
            priceLabel.textColor = .systemGray
            bargainPriceLabel.isHidden = false
            bargainPriceLabel.text = "\(currency.rawValue) \(bargainPrice.formattedWithComma())"
        }
    }
    
    private func changeStockLabel(by stock: Int) {
        if stock == 0 {
            stockLabel.isHidden = false
            stockLabel.text = "품절"
        }
    }
    
    private func calculateBargainRate(price: Double, discountedPrice: Double) {
        let bargainRate = ceil(discountedPrice / price * 100)
        
        if discountedPrice != .zero {
            bargainRateLabel.text = "\(String(format: "%.0f", bargainRate))%"
        }
    }
}
