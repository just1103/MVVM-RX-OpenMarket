import UIKit

class TableListCell: UICollectionViewCell {
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
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
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
        return label
    }()

    private let accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: Design.accessoryImageName)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let nameAndStockStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
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
        return label
    }()
    
    private let bargainPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Design.priceLabelFont
        label.textColor = Design.priceLabelTextColor
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
    
    private let priceAndBargainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(verticalStackView)
        
        verticalStackView.addArrangedSubview(nameAndStockStackView)
        nameAndStockStackView.addArrangedSubview(nameLabel)
        nameAndStockStackView.addArrangedSubview(stockLabel)
        nameAndStockStackView.addArrangedSubview(accessoryImageView)
        
        verticalStackView.addArrangedSubview(priceAndBargainStackView)
        priceAndBargainStackView.addArrangedSubview(bargainPriceLabel)
        priceAndBargainStackView.addArrangedSubview(priceLabel)
        priceAndBargainStackView.addArrangedSubview(bargainRateLabel)
    }
    
    func apply(data: Product) {
        imageView.loadImage(of: data.thumbnail)
        nameLabel.text = data.name
        changePriceAndDiscountedPriceLabel(price: data.price,
                                           discountedPrice: data.discountedPrice,
                                           bargainPrice: data.bargainPrice,
                                           currency: data.currency)
        changeStockLabel(by: data.stock)
    }
    
    private func changePriceAndDiscountedPriceLabel(price: Double,
                                                    discountedPrice: Double,
                                                    bargainPrice: Double,
                                                    currency: Currency) {
        if discountedPrice == 0 {
            priceLabel.attributedText = nil
            priceLabel.textColor = .systemGray
            priceLabel.text = "\(currency.rawValue) \(price.formattedWithComma())"
            
            bargainPriceLabel.isHidden = true
        } else {
            let priceText = "\(currency.rawValue) \(price.formattedWithComma())"
            priceLabel.strikeThrough(text: priceText)
            priceLabel.textColor = .systemRed
            
            bargainPriceLabel.isHidden = false
            bargainPriceLabel.text = "\(currency.rawValue) \(bargainPrice.formattedWithComma())"
        }
    }
    
    private func changeStockLabel(by stock: Int) {
        if stock == 0 {
            stockLabel.isHidden = false
            stockLabel.text = "품절"
//            stockLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        } else {
            stockLabel.isHidden = true
        }
    }
}
