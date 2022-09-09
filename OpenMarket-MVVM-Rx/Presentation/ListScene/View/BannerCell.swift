import UIKit

final class BannerCell: UICollectionViewCell {
    // MARK: - Properties
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.style(axis: .vertical, alignment: .fill, distribution: .fill)
        return stackView
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
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
    }
    
    // MARK: - Methods
    func apply(imageURL: String, productID: Int) {
        imageView.loadCachedImage(of: imageURL)
        self.productID = productID
    }
    
    private func configureUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
