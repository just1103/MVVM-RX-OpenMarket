import UIKit

class MenuSegmentedControl: UIView {
    // MARK: - Nested Type
    enum Content {
        static let tableButtonTitle = "Table로 보기"
        static let gridButtonTitle = "Grid로 보기"
    }
    
    // MARK: Properties
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    private let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Content.gridButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.setTitleColor(.systemGray, for: .normal)
        return button
    }()
    
    private let tableButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Content.tableButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.setTitleColor(.systemGray, for: .normal)
        return button
    }()
    
    private let selectorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
        view.tintColor = .red
        view.backgroundColor = .label
        return view
    }()
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    func changeSelectedUI(sender: ProductListViewModel.MenuButton) {
        switch sender {
        case .grid:
            gridButton.setTitleColor(.label, for: .normal)
            gridButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
            tableButton.setTitleColor(.systemGray, for: .normal)
            tableButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            selectorView.widthAnchor.constraint(equalTo: gridButton.widthAnchor).isActive = true
        case .table:
            tableButton.setTitleColor(.label, for: .normal)
            tableButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
            gridButton.setTitleColor(.systemGray, for: .normal)
            gridButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            selectorView.widthAnchor.constraint(equalTo: tableButton.widthAnchor).isActive = true
        }
    }
    
    private func configureUI() {
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(gridButton)
        buttonStackView.addArrangedSubview(tableButton)
        addSubview(selectorView)
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: self.topAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: selectorView.topAnchor),
            selectorView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -7)
        ])
        changeSelectedUI(sender: .grid)
    }
}
