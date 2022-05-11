import UIKit
import RxSwift
import RxCocoa

class ProductDetailViewController: UIViewController {
    // MARK: - Nested Types
    enum Design {
        static let backgroundColor = #colorLiteral(red: 0.9524367452, green: 0.9455882907, blue: 0.9387311935, alpha: 1)
        static let lightGreenColor = #colorLiteral(red: 0.5567998886, green: 0.7133290172, blue: 0.6062341332, alpha: 1)
        static let darkGreenColor = #colorLiteral(red: 0.137904644, green: 0.3246459067, blue: 0.2771841288, alpha: 1)
        static let veryDarkGreenColor = #colorLiteral(red: 0.04371468723, green: 0.1676974297, blue: 0.1483464539, alpha: 1)
        static let nameLabelFont: UIFont = .preferredFont(forTextStyle: .largeTitle)
        static let stockLabelFont: UIFont = .preferredFont(forTextStyle: .body)
        static let stockLabelTextColor: UIColor = .label
        static let accessoryImageName: String = "chevron.right"
        static let priceLabelFont: UIFont = .preferredFont(forTextStyle: .title3)
        static let originalPriceLabelFont: UIFont = .preferredFont(forTextStyle: .callout)
        static let priceLabelTextColor: UIColor = .systemRed
        static let bargainRateLabelFont: UIFont = .preferredFont(forTextStyle: .body)
        static let bargainRateLabelTextColor: UIColor = .systemRed
        static let descriptionTextViewFont: UIFont = .preferredFont(forTextStyle: .body)
    }
    
    // MARK: - Properties
    // TODO: Custom ScrollView 타입 생성하여 코드 분리할지 고려
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = Design.backgroundColor
        return scrollView
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private let imageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 0.85).isActive = true
        collectionView.backgroundColor = Design.backgroundColor
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let imagePageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = .systemGray
        pageControl.currentPageIndicatorTintColor = Design.darkGreenColor
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private let productInformationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        stackView.spacing = 10
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Design.nameLabelFont
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private let priceContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .firstBaseline
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.setContentHuggingPriority(.required, for: .vertical)
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
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let bargainPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Design.priceLabelFont
        label.textColor = Design.priceLabelTextColor
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let bargainRateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = Design.bargainRateLabelFont
        label.textColor = Design.bargainRateLabelTextColor
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let topBorderLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40).isActive = true
        view.setContentHuggingPriority(.required, for: .vertical)
        view.backgroundColor = .gray
        return view
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Design.stockLabelFont
        label.textColor = Design.stockLabelTextColor
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private let registrationDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Design.stockLabelFont
        label.textColor = Design.stockLabelTextColor
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private let descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        return stackView
    }()
    
    private let bottomBorderLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40).isActive = true
        view.setContentHuggingPriority(.required, for: .vertical)
        view.backgroundColor = .gray
        return view
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = Design.backgroundColor
        textView.font = Design.descriptionTextViewFont
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textAlignment = .left
        textView.textContainer.lineFragmentPadding = .zero
        return textView
    }()
    
    private var viewModel: ProductDetailViewModel!
    private let invokedViewDidLoad = PublishSubject<Void>()
    private let cellDidScroll = PublishSubject<IndexPath>()
    private let currentBannerPage = PublishSubject<Int>()
    private var previousBannerPage = 0
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    convenience init(viewModel: ProductDetailViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        bind()
        invokedViewDidLoad.onNext(())
    }
    
    // MARK: - Methods
    private func configureUI() {
        view.backgroundColor = Design.backgroundColor
        view.addSubview(scrollView)
        scrollView.addSubview(containerStackView)

        containerStackView.addArrangedSubview(imageCollectionView)
        containerStackView.addArrangedSubview(imagePageControl)
        containerStackView.addArrangedSubview(productInformationStackView)
        containerStackView.addArrangedSubview(descriptionStackView)
        
        productInformationStackView.addArrangedSubview(nameLabel)
        productInformationStackView.addArrangedSubview(priceContainerStackView)
        productInformationStackView.addArrangedSubview(topBorderLine)
        productInformationStackView.addArrangedSubview(stockLabel)
        productInformationStackView.addArrangedSubview(registrationDateLabel)
        
        priceContainerStackView.addArrangedSubview(priceAndBargainpriceStackView)
        priceContainerStackView.addArrangedSubview(bargainRateLabel)
        
        priceAndBargainpriceStackView.addArrangedSubview(bargainPriceLabel)
        priceAndBargainpriceStackView.addArrangedSubview(priceLabel)
        
        descriptionStackView.addArrangedSubview(bottomBorderLine)
        descriptionStackView.addArrangedSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            containerStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    private func configureCollectionView() {
        imageCollectionView.register(ProductDetailImageCell.self,
                                     forCellWithReuseIdentifier: String(describing: ProductDetailImageCell.self))
        imageCollectionView.collectionViewLayout = createCollectionViewLayout()
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            let screenWidth = UIScreen.main.bounds.width
            let estimatedHeight = NSCollectionLayoutDimension.estimated(screenWidth)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: estimatedHeight)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85),
                                                   heightDimension: estimatedHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.visibleItemsInvalidationHandler = { [weak self] _, contentOffset, environment in
                self?.imagePageControl.currentPage = Int(max(0, round(contentOffset.x / environment.container.contentSize.width)))
            }
            return section
        }
        return layout
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
            priceLabel.font = Design.originalPriceLabelFont
            bargainPriceLabel.isHidden = false
            bargainPriceLabel.text = "\(currency.rawValue) \(bargainPrice.formattedWithComma())"
        }
    }
    
    private func changeStockLabel(by stock: Int) {
        if stock == 0 {
            stockLabel.text = "재고 수량: 품절"
        } else {
            stockLabel.text = "재고 수량: \(stock)개"
        }
    }
    
    private func calculateBargainRate(price: Double, discountedPrice: Double) {
        let bargainRate = ceil(discountedPrice / price * 100)
        
        if discountedPrice != .zero {
            bargainRateLabel.text = "\(String(format: "%.0f", bargainRate))%"
        }
    }
}

extension ProductDetailViewController {
    private func bind() {
        let input = ProductDetailViewModel.Input(invokedViewDidLoad: invokedViewDidLoad.asObservable(),
                                                 cellDidScroll: cellDidScroll.asObservable())
        
        let output = viewModel.transform(input)
        
        configureProductDetail(with: output.product, images: output.productImages)
    }
    
    private func configureProductDetail(with productDetail: Observable<DetailViewProduct>,
                                        images: Observable<[ProductImage]>) {
        productDetail
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] productDetail in
                self?.apply(data: productDetail)
            })
            .disposed(by: disposeBag)
        images
            .bind(to: imageCollectionView.rx.items(cellIdentifier: String(describing: ProductDetailImageCell.self),
                                                   cellType: ProductDetailImageCell.self)) { _, item, cell in
                cell.apply(with: item.url)
            }
            .disposed(by: disposeBag)
    }
    
    private func apply(data: DetailViewProduct) {
        imagePageControl.numberOfPages = data.images.count
        imagePageControl.hidesForSinglePage = true
        nameLabel.text = data.name
        changePriceAndDiscountedPriceLabel(price: data.price,
                                           discountedPrice: data.discountedPrice,
                                           bargainPrice: data.bargainPrice,
                                           currency: data.currency)
        calculateBargainRate(price: data.price, discountedPrice: data.discountedPrice)
        changeStockLabel(by: data.stock)
        registrationDateLabel.text = "상품 등록일: \(DateFormatter.common.string(from: data.createdAt))"
        descriptionTextView.text = data.description
    }
}
