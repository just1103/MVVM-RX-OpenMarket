import UIKit
import RxCocoa
import RxSwift

final class MenuSegmentedControl: UIView {
    // MARK: - Nested Types
    private enum Content {
        static let gridButtonTitle = "Grid로 보기"
        static let tableButtonTitle = "Table로 보기"
    }
    
    private enum Design {
        static let defaultButtonTitleFont: UIFont = .systemFont(ofSize: 23)
        static let highlightedButtonTitleFont: UIFont = .boldSystemFont(ofSize: 23)
        
        static let defaultButtonTitleColor: UIColor = .systemGray
        static let highlightedButtonTitleColor: UIColor = CustomColor.backgroundColor
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
        button.titleLabel?.font = Design.defaultButtonTitleFont
        button.setTitleColor(Design.defaultButtonTitleColor, for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    private let tableButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Content.tableButtonTitle, for: .normal)
        button.titleLabel?.font = Design.defaultButtonTitleFont
        button.setTitleColor(Design.defaultButtonTitleColor, for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    private let selectorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
        view.backgroundColor = CustomColor.backgroundColor
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()
    
    private(set) var viewModel: MenuSegmentedControlViewModel!
    private let disposeBag = DisposeBag()
    
    // MARK: Initializers
    convenience init(viewModel: MenuSegmentedControlViewModel) {
        self.init()
        self.viewModel = viewModel
        configureUI()
        bind()
    }

    // MARK: - Methods
    private func configureUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
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
            selectorView.widthAnchor.constraint(equalTo: gridButton.widthAnchor)
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
            gridButton.setTitleColor(Design.highlightedButtonTitleColor, for: .normal)
            gridButton.titleLabel?.font = Design.highlightedButtonTitleFont
            tableButton.setTitleColor(Design.defaultButtonTitleColor, for: .normal)
            tableButton.titleLabel?.font = Design.defaultButtonTitleFont

            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                // FIXME: origin과 widthAnchor를 설정했는데, horizontal position을 못잡는 문제
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
            tableButton.setTitleColor(Design.highlightedButtonTitleColor, for: .normal)
            tableButton.titleLabel?.font = Design.highlightedButtonTitleFont
            gridButton.setTitleColor(Design.defaultButtonTitleColor, for: .normal)
            gridButton.titleLabel?.font = Design.defaultButtonTitleFont
            
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
