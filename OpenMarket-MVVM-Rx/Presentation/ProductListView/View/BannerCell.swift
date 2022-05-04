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
//        let height = UIScreen.main.bounds.height / 3
//        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true // esto
//        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
//        imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        let width = UIScreen.main.bounds.width
        imageView.widthAnchor.constraint(equalToConstant: 428).isActive = true
//        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
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
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func apply(imageURL: String) {
        imageView.loadImage(of: imageURL)
    }
}
