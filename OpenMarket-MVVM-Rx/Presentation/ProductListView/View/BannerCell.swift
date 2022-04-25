import UIKit

class BannerCell: UICollectionViewCell {
    private enum Design {
        static let imageViewInset: CGFloat = 8.0
    }
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: Design.imageViewInset),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Design.imageViewInset),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: Design.imageViewInset),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: Design.imageViewInset)
        ])
    }
    
    func apply(image: UIImage) {
        self.imageView.image = image
    }
}
