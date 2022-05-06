import UIKit
import RxCocoa
import RxSwift

class MenuSegmentedControl: UIView {
    // MARK: - Nested Type
    enum Content {
        static let gridButtonTitle = "Grid로 보기"
        static let tableButtonTitle = "Table로 보기"
    }
    
    // MARK: Properties
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 50
        return stackView
    }()
    
    private let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Content.gridButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.setTitleColor(.systemGray, for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    private let tableButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Content.tableButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.setTitleColor(.systemGray, for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    private let selectorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
//        view.tintColor = .red
        view.backgroundColor = .label
        return view
    }()
    
    private let viewModel = MenuSegmentedControlViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        bind()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
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
            selectorView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -7),
            selectorView.widthAnchor.constraint(equalTo: gridButton.widthAnchor) // TODO: 각 Button Label의 Width에 맞게 변하도록 수정
        ])
        changeSelectedUI(sender: .grid)
    }
    
    func bind() {
        let input = MenuSegmentedControlViewModel.Input(gridButtonDidTap: gridButton.rx.tap.asObservable(), 
                                                        tableButtonDidTap: tableButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input)
        
        output.selectedGridButton
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.changeSelectedUI(sender: .grid)
            })
            .disposed(by: disposeBag)
        
        output.selectedTableButton
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.changeSelectedUI(sender: .table)
            })
            .disposed(by: disposeBag)
    }
    
    private func changeSelectedUI(sender: MenuSegmentedControlViewModel.MenuButton) {
        switch sender {
        case .grid:
            gridButton.setTitleColor(.label, for: .normal)
            gridButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
            tableButton.setTitleColor(.systemGray, for: .normal)
            tableButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)

            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.selectorView.frame.origin.x = self.gridButton.frame.origin.x
            }
            
            // TODO: deactivate 안됨
//            NSLayoutConstraint.deactivate([
//                selectorView.leadingAnchor.constraint(equalTo: tableButton.leadingAnchor),
//                selectorView.trailingAnchor.constraint(equalTo: tableButton.trailingAnchor)
//            ])
//            NSLayoutConstraint.activate([
//                selectorView.leadingAnchor.constraint(equalTo: gridButton.leadingAnchor),
//                selectorView.trailingAnchor.constraint(equalTo: gridButton.trailingAnchor)
//            ])
        case .table:
            tableButton.setTitleColor(.label, for: .normal)
            tableButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
            gridButton.setTitleColor(.systemGray, for: .normal)
            gridButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.selectorView.frame.origin.x = self.tableButton.frame.origin.x
            }
            
//            NSLayoutConstraint.deactivate([
//                selectorView.leadingAnchor.constraint(equalTo: gridButton.leadingAnchor),
//                selectorView.trailingAnchor.constraint(equalTo: gridButton.trailingAnchor)
//            ])
//            NSLayoutConstraint.activate([
//                selectorView.leadingAnchor.constraint(equalTo: tableButton.leadingAnchor),
//                selectorView.trailingAnchor.constraint(equalTo: tableButton.trailingAnchor)
//            ])
        }
    }
}
