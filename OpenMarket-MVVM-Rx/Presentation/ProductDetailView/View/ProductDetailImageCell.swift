import UIKit

class ProductDetailImageCell: UICollectionViewCell {
    // MARK: - Properties
    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.layer.cornerRadius = 6
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
    
    // MARK: - Methods
    func apply(with imageURL: String) {
        productImageView.loadImage(of: imageURL)
    }
    
    private func configureUI() {
        addSubview(productImageView)
        productImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        productImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        productImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        productImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}
