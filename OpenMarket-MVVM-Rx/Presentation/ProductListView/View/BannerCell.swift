import UIKit

class BannerCell: UICollectionViewCell {
    private enum Design {
        static let imageViewInset: CGFloat = 0
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
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
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: Design.imageViewInset),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Design.imageViewInset),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1 * Design.imageViewInset),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * Design.imageViewInset)
        ])
    }
    
    func apply(imageURL: String) {
        imageView.loadImage(of: imageURL)
    }
}
