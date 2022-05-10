import UIKit

class TableListCell: UICollectionViewCell {
    // MARK: - Nested Types
    private enum Design {
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
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill // fillProportionally하면 계산에 시간이 오래걸려서 Cell이 늦게 뜸
        stackView.spacing = 8
        
        let verticalInset: Double = 10
        let horizontalInset: Double = 10
        stackView.layoutMargins = UIEdgeInsets(top: verticalInset,
                                               left: horizontalInset,
                                               bottom: verticalInset,
                                               right: horizontalInset)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        return imageView
    }()
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let nameAndStockStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.spacing = 10
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Design.nameLabelFont
        return label
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = Design.stockLabelFont
        label.textColor = Design.stockLabelTextColor
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: Design.accessoryImageName)
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    private let priceAndBargainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Design.priceLabelFont
        label.textColor = Design.priceLabelTextColor
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let bargainPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Design.priceLabelFont
        label.textColor = Design.priceLabelTextColor
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let bargainRateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = Design.bargainRateLabelFont
        label.textColor = Design.bargainRateLabelTextColor
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal) // 주의 - default Hugging이 251이 아니라 250임
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
        fatalError("init(coder:) has not been implemented")
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
        priceLabel.textColor = .systemRed
        stockLabel.isHidden = true
    }
    
    // MARK: - Methods
    func apply(data: Product) {
        imageView.loadImage(of: data.thumbnail)
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
        containerStackView.addArrangedSubview(verticalStackView)
        containerStackView.addArrangedSubview(accessoryImageView)
        
        verticalStackView.addArrangedSubview(nameAndStockStackView)
        nameAndStockStackView.addArrangedSubview(nameLabel)
        nameAndStockStackView.addArrangedSubview(stockLabel)
        
        verticalStackView.addArrangedSubview(priceAndBargainStackView)
        priceAndBargainStackView.addArrangedSubview(bargainPriceLabel)
        priceAndBargainStackView.addArrangedSubview(priceLabel)
        priceAndBargainStackView.addArrangedSubview(bargainRateLabel)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 0.2),
        ])
    }

    private func changePriceAndDiscountedPriceLabel(price: Double,
                                                    discountedPrice: Double,
                                                    bargainPrice: Double,
                                                    currency: Currency) {
        if discountedPrice == 0 {
            priceLabel.attributedText = nil
            priceLabel.textColor = .systemRed
            priceLabel.text = "\(currency.rawValue) \(price.formattedWithComma())"
            
            bargainPriceLabel.isHidden = true
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
        } else {
            stockLabel.isHidden = true
        }
    }
    
    private func calculateBargainRate(price: Double, discountedPrice: Double) {
        let bargainRate = ceil(discountedPrice / price * 100)
        
        if discountedPrice != .zero {
            bargainRateLabel.text = "\(String(format: "%.0f", bargainRate))%"
        }
    }
}
