import UIKit

final class GridListCell: UICollectionViewCell {
    // MARK: - Properties
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.style(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 8)
        stackView.setupMargins(verticalInset: 15, horizontalInset: 15)
        return stackView
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        return imageView
    }()
    private let nameAndStockStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.style(axis: .horizontal, alignment: .fill, distribution: .fill)
        return stackView
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.style(textAlignment: .left, font: Design.nameLabelFont, textColor: Design.nameLabelTextColor)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.style(textAlignment: .right, font: Design.stockLabelFont, textColor: Design.stockLabelTextColor)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    private let priceContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.style(axis: .horizontal, alignment: .top, distribution: .fill, spacing: 8)
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
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    private let bargainPriceLabel: UILabel = {
        let label = UILabel()
        label.style(textAlignment: .left, font: Design.priceLabelFont, textColor: Design.priceLabelTextColor)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    private let bargainRateLabel: UILabel = {
        let label = UILabel()
        label.style(textAlignment: .right, font: Design.bargainRateLabelFont, textColor: Design.bargainRateLabelTextColor)
        return label
    }()
    
    private(set) var productID: Int = 0
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    // MARK: - Lifecycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
        stockLabel.text = nil
        bargainPriceLabel.text = nil
        bargainPriceLabel.isHidden = true
        bargainRateLabel.text = nil
        priceLabel.attributedText = nil
        priceLabel.text = nil
        priceLabel.textColor = Design.priceLabelTextColor
        stockLabel.isHidden = true
    }
    
    // MARK: - Methods
    func apply(data: Product) {
        imageView.loadCachedImage(of: data.thumbnail)
        nameLabel.text = data.name
        changePriceAndDiscountedPriceLabel(price: data.price,
                                           discountedPrice: data.discountedPrice,
                                           bargainPrice: data.bargainPrice,
                                           currency: data.currency)
        changeStockLabel(by: data.stock)
        calculateBargainRate(price: data.price, discountedPrice: data.discountedPrice)
        self.productID = data.id
    }
    
    private func configureUI() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(nameAndStockStackView)
        containerStackView.addArrangedSubview(priceContainerStackView)
        
        nameAndStockStackView.addArrangedSubview(nameLabel)
        nameAndStockStackView.addArrangedSubview(stockLabel)
        
        priceContainerStackView.addArrangedSubview(priceAndBargainpriceStackView)
        priceContainerStackView.addArrangedSubview(bargainRateLabel)
        priceAndBargainpriceStackView.addArrangedSubview(bargainPriceLabel)
        priceAndBargainpriceStackView.addArrangedSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
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
            priceLabel.textColor = Design.discountedPriceLabelTextColor
            bargainPriceLabel.isHidden = false
            bargainPriceLabel.text = "\(currency.rawValue) \(bargainPrice.formattedWithComma())"
        }
    }
    
    private func changeStockLabel(by stock: Int) {
        if stock == 0 {
            stockLabel.isHidden = false
            stockLabel.text = Content.outOfStockLabelText
        }
    }
    
    private func calculateBargainRate(price: Double, discountedPrice: Double) {
        let bargainRate = ceil(discountedPrice / price * 100)
        
        if discountedPrice != .zero {
            bargainRateLabel.text = "\(String(format: "%.0f", bargainRate))%"
        }
    }
}

// MARK: - NameSpaces
extension GridListCell {
    private enum Design {
        static let nameLabelTextColor: UIColor = .black
        static let stockLabelTextColor: UIColor = .systemOrange
        static let priceLabelTextColor: UIColor = .systemRed
        static let discountedPriceLabelTextColor: UIColor = .systemGray
        static let bargainRateLabelTextColor: UIColor = .systemRed
        
        static let nameLabelFont: UIFont = .preferredFont(forTextStyle: .title3)
        static let stockLabelFont: UIFont = .preferredFont(forTextStyle: .title3)
        static let priceLabelFont: UIFont = .preferredFont(forTextStyle: .headline)
        static let bargainRateLabelFont: UIFont = .preferredFont(forTextStyle: .body)
        
        static let accessoryImageName: String = "chevron.right"
    }
    
    private enum Content {
        static let outOfStockLabelText = "품절"
    }
}
