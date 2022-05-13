import UIKit

class ProductDetailImageCell: UICollectionViewCell {
    // MARK: - Properties
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .black
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
    }
    
    // MARK: - Methods
    func apply(with imageURL: String) {
        productImageView.loadImage(of: imageURL)
    }
    
    private func configureUI() {
        addSubview(productImageView)
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            productImageView.topAnchor.constraint(equalTo: self.topAnchor),
            productImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
