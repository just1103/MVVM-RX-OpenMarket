import UIKit
import RxSwift
import RxCocoa

final class ProductDetailViewController: UIViewController {
    // MARK: - Nested Types
    private enum Design {
        static let nameLabelTextColor: UIColor = .black
        static let stockLabelTextColor: UIColor = .black
        static let priceLabelTextColor: UIColor = .systemRed
        static let bargainRateLabelTextColor: UIColor = .systemRed
        static let descriptionTextViewTextColor: UIColor = .black
        
        static let nameLabelFont: UIFont = .preferredFont(forTextStyle: .largeTitle)
        static let stockLabelFont: UIFont = .preferredFont(forTextStyle: .body)
        static let priceLabelFont: UIFont = .preferredFont(forTextStyle: .title3)
        static let originalPriceLabelFont: UIFont = .preferredFont(forTextStyle: .callout)
        static let bargainRateLabelFont: UIFont = .preferredFont(forTextStyle: .body)
        static let descriptionTextViewFont: UIFont = .preferredFont(forTextStyle: .body)
        
        static let accessoryImageName: String = "chevron.right"
        static let containerHorizontalInset: CGFloat = 20
    }
    
    private enum Content {
        static let outOfStockLabelText = "재고 수량: 품절"
        static func stockLabelText(with stock: Int) -> String {
            return "재고 수량: \(stock)개"
        }
        static func registrationDateLabelText(with date: Date) -> String {
            "상품 등록일: \(DateFormatter.common.string(from: date))"
        }
        static func bargainRateLabelText(with bargainRate: Double) -> String {
            return "\(String(format: "%.0f", bargainRate))%"
        }
    }
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = CustomColor.backgroundColor
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.style(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 10)
        return stackView
    }()
    private let imageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 0.85).isActive = true
        collectionView.backgroundColor = CustomColor.backgroundColor
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    private let imagePageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = .systemGray
        pageControl.currentPageIndicatorTintColor = CustomColor.darkGreenColor
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    private let productInformationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.style(axis: .vertical,
                        alignment: .fill,
                        distribution: .fill,
                        spacing: 10)
        stackView.setupMargins(horizontalInset: Design.containerHorizontalInset)
        return stackView
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.style(textAlignment: .left,
                    font: Design.nameLabelFont,
                    textColor: Design.nameLabelTextColor,
                    numberOfLines: 0)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    private let priceContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.style(axis: .horizontal, alignment: .firstBaseline, distribution: .fill, spacing: 8)
        return stackView
    }()
    private let priceAndBargainpriceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.style(axis: .vertical, alignment: .fill, distribution: .fill)
        return stackView
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.style(textAlignment: .left, font: Design.priceLabelFont, textColor: Design.priceLabelTextColor)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    private let bargainPriceLabel: UILabel = {
        let label = UILabel()
        label.style(textAlignment: .left, font: Design.priceLabelFont, textColor: Design.priceLabelTextColor)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    private let bargainRateLabel: UILabel = {
        let label = UILabel()
        label.style(textAlignment: .right,
                    font: Design.bargainRateLabelFont,
                    textColor: Design.bargainRateLabelTextColor)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    private let topBorderLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - Design.containerHorizontalInset * 2).isActive = true
        view.setContentHuggingPriority(.required, for: .vertical)
        view.backgroundColor = .gray
        return view
    }()
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.style(textAlignment: .left, font: Design.stockLabelFont, textColor: Design.stockLabelTextColor)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    private let registrationDateLabel: UILabel = {
        let label = UILabel()
        label.style(textAlignment: .left, font: Design.stockLabelFont, textColor: Design.stockLabelTextColor)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    private let descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.style(axis: .vertical, alignment: .fill, distribution: .fill)
        stackView.setupMargins(horizontalInset: Design.containerHorizontalInset)
        return stackView
    }()
    private let bottomBorderLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - Design.containerHorizontalInset * 2).isActive = true
        view.setContentHuggingPriority(.required, for: .vertical)
        view.backgroundColor = .gray
        return view
    }()
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = CustomColor.backgroundColor
        textView.font = Design.descriptionTextViewFont
        textView.textColor = Design.descriptionTextViewTextColor
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textAlignment = .left
        textView.textContainer.lineFragmentPadding = .zero
        textView.dataDetectorTypes = .all
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
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
        configureCollectionView()
        bind()
        invokedViewDidLoad.onNext(())
    }
    
    // MARK: - Methods
    private func configureUI() {
        view.backgroundColor = CustomColor.darkGreenColor
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

            containerStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            containerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = CustomColor.backgroundColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: CustomColor.backgroundColor]
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
                let bannerIndex = Int(max(0, round(contentOffset.x / environment.container.contentSize.width)))
                self?.imagePageControl.currentPage = bannerIndex
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
            stockLabel.text = Content.outOfStockLabelText
        } else {
            stockLabel.text = Content.stockLabelText(with: stock)
        }
    }
    
    private func calculateBargainRate(price: Double, discountedPrice: Double) {
        let bargainRate = ceil(discountedPrice / price * 100)
        
        if discountedPrice != .zero {
            bargainRateLabel.text = Content.bargainRateLabelText(with: bargainRate)
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
        self.navigationItem.leftBarButtonItem = nil
        navigationItem.title = data.name
        navigationItem.backBarButtonItem?.customView?.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        imagePageControl.numberOfPages = data.images.count
        imagePageControl.hidesForSinglePage = true
        nameLabel.text = data.name
        changePriceAndDiscountedPriceLabel(price: data.price,
                                           discountedPrice: data.discountedPrice,
                                           bargainPrice: data.bargainPrice,
                                           currency: data.currency)
        calculateBargainRate(price: data.price, discountedPrice: data.discountedPrice)
        changeStockLabel(by: data.stock)
        registrationDateLabel.text = Content.registrationDateLabelText(with: data.createdAt)
        descriptionTextView.text = data.description
    }
}
