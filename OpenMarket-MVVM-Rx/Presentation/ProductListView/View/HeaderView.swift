import UIKit

class HeaderView: UICollectionReusableView {
    // MARK: - Nested Type
    enum Design {
        static let darkGreenColor = #colorLiteral(red: 0.137904644, green: 0.3246459067, blue: 0.2771841288, alpha: 1)
    }
    
    // MARK: - Property
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = Design.darkGreenColor
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        self.isHidden = false
    }
    
    func apply(_ indexPath: IndexPath) {
        if indexPath.section == 0 {
            titleLabel.text = "⏰ 놓치면 후회할 가격"
        } else {
            titleLabel.text = "♥️ 전체 상품 보기"
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
