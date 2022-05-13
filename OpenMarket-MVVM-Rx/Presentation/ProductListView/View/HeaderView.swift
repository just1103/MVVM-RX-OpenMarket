import UIKit

final class HeaderView: UICollectionReusableView {
    // MARK: - Nested Types
    private enum Design {
        static let titleLabelFont: UIFont = .preferredFont(forTextStyle: .title3)
    }
    
    private enum Content {
        static let bannerSectionTitle = "⏰ 놓치면 후회할 가격"
        static let listSectionTitle = "🍎 전체 상품 보기"
    }
    
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.style(textAlignment: .left, font: Design.titleLabelFont, textColor: CustomColor.darkGreenColor)
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        self.isHidden = false
    }
    
    func apply(_ indexPath: IndexPath) {
        if indexPath.section == 0 {
            titleLabel.text = Content.bannerSectionTitle
        } else {
            titleLabel.text = Content.listSectionTitle
        }
    }
    
    private func configureUI() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
}
