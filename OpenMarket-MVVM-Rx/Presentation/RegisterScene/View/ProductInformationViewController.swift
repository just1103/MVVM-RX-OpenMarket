//
//  ProductRegisterViewController.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/09.
//

import UIKit
import RxSwift
import RxCocoa

class ProductInformationViewController: UIViewController { // TODO: subclass - 상품 등록, 상품 수정
    // MARK: - Properties
    private let productInfoScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .backgroundColor
        return scrollView
    }()
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.style(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 10)
        let inset: CGFloat = 15
        stackView.setupMargins(verticalInset: inset, horizontalInset: inset)
        return stackView
    }()
    private(set) var imageCollectionView = ProductImageCollectionView(frame: CGRect.zero,
                                                                      collectionViewLayout: UICollectionViewFlowLayout())
    private(set) var nameTextField = RoundedRectTextField()
    private let priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.style(axis: .horizontal, alignment: .top, distribution: .fillProportionally, spacing: 8)
//        stackView.setContentHuggingPriority(.required, for: .vertical)
        return stackView
    }()
    private(set) var priceTextField = RoundedRectTextField()
    private(set) lazy var currencySegmentedControl: UISegmentedControl = {
        let items = Currency.allCases.map { $0.description }
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .white
        segmentedControl.setTitleTextAttributes([.font: UIFont.preferredFont(forTextStyle: .body)], for: .normal)
        segmentedControl.setTitleTextAttributes([.font: UIFont.preferredFont(forTextStyle: .headline)], for: .selected)
        segmentedControl.setContentHuggingPriority(.required, for: .horizontal)
        return segmentedControl
    }()
    private(set) var discountedPriceTextField = RoundedRectTextField()
    private(set) var stockTextField = RoundedRectTextField()
    private(set) var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.lightGray
        textView.isScrollEnabled = false
        textView.font = .preferredFont(forTextStyle: .body)
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return textView
    }()
    
    private var viewModel: ProductInformationViewModel!
    private let invokedViewDidLoad = PublishSubject<Void>()
    private let leftBarButtonDidTap = PublishSubject<Void>()
    private let rightBarButtonDidTap = PublishSubject<ProductDetailToRegister>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    convenience init(viewModel: ProductInformationViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
        bind()
        invokedViewDidLoad.onNext(())
    }
    
    // MARK: - Methods
    private func configureUI() {
        view.backgroundColor = .darkGreenColor
        view.addSubview(productInfoScrollView)
        setupVerticalStackView()
        setupImageCollectionView()
        setupTextFields()
        setupDescriptionTextView()

        NSLayoutConstraint.activate([
            productInfoScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            productInfoScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            productInfoScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            productInfoScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // FIXME: Scroll 구역을 인지 못하는 문제
//            productInfoScrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor),
            productInfoScrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: productInfoScrollView.widthAnchor),
        ])
    }
    
    private func setupVerticalStackView() {
        view.addSubview(containerStackView)
        containerStackView.addArrangedSubview(imageCollectionView)
        containerStackView.addArrangedSubview(nameTextField)
        containerStackView.addArrangedSubview(priceStackView)
        containerStackView.addArrangedSubview(discountedPriceTextField)
        containerStackView.addArrangedSubview(stockTextField)
        containerStackView.addArrangedSubview(descriptionTextView)
        priceStackView.addArrangedSubview(priceTextField)
        priceStackView.addArrangedSubview(currencySegmentedControl)
        
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerStackView.topAnchor.constraint(equalTo: view.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageCollectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.35),
        ])
    }
    
    private func setupImageCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 14
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.width * 0.3)
        imageCollectionView.collectionViewLayout = flowLayout
        imageCollectionView.register(cellType: ProductImageCell.self)
        imageCollectionView.register(reusableFooterViewType: ProductRegisterImageFooterView.self)
        imageCollectionView.delegate = self
    }
    
    private func setupTextFields() {
        nameTextField.placeholder = ProductPlaceholder.name.text
        priceTextField.placeholder = ProductPlaceholder.price.text
        priceTextField.keyboardType = .decimalPad
        discountedPriceTextField.placeholder = ProductPlaceholder.discountedPrice.text
        discountedPriceTextField.keyboardType = .decimalPad
        stockTextField.placeholder = ProductPlaceholder.stock.text
        stockTextField.keyboardType = .decimalPad
    }
    
    private func setupDescriptionTextView() {
        descriptionTextView.text = ProductPlaceholder.description.text
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "상품 등록"  // TODO: ViewModel에서 kind 받아서 처리
        navigationController?.navigationBar.tintColor = .backgroundColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.backgroundColor]
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: nil,
                                                           action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(touchUpDoneButton))
    }
    
    @objc private func touchUpDoneButton() {
        let userInputData = UserInputToRegister(
            name: nameTextField.text,
            price: priceTextField.text,
            discountPrice: discountedPriceTextField.text,
            stock: stockTextField.text,
            currencyIndex: currencySegmentedControl.selectedSegmentIndex,
            descriptionText: descriptionTextView.text
        )
        let userInputValidationResult = UserInputDataFactory.create(userInputData)
                                 
        switch userInputValidationResult {
        case .success(let productDetailToRegister):
            rightBarButtonDidTap.onNext(productDetailToRegister)
            showRegisterSuccessAlert()
        case .failure(let error):
            showRegisterFailAlert(message: error.description)
        }
    }
}

// MARK: - Rx Binding Methods
extension ProductInformationViewController {
    private func bind() {
        let input = ProductInformationViewModel.Input(
            invokedViewDidLoad: invokedViewDidLoad.asObservable(),
            leftBarButtonDidTap: navigationItem.leftBarButtonItem?.rx.tap.asObservable(),
            rightBarButtonDidTap: navigationItem.rightBarButtonItem?.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input)
    }
}

// MARK: - ImageCollectionView Delegate
extension ProductInformationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        // TODO: viewModel.images.count > 4로 분기처리
        return CGSize(width: UIScreen.main.bounds.width * 0.36,
                      height: UIScreen.main.bounds.width * 0.35)
    }
}
    
// MARK: - ProductRegister Result Alert
extension ProductInformationViewController {
    func showRegisterSuccessAlert() {
        let okButton = UIAlertAction(title: ProductRegisterAlertText.confirm.description,
                                     style: .default) { [weak self] _ in
            // Todo: ViewModel에서 처리, 첫번째 화면한테 상품 갱신하라고 시켜라
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        let alert =  AlertFactory().createAlert(title: ProductRegisterAlertText.successTitle.description,
                                                actions: okButton)

        present(alert, animated: true)
    }
    
    func showRegisterFailAlert(message: ProductRegisterAlertText) {
        let okButton = UIAlertAction(title: ProductRegisterAlertText.confirm.description, style: .default)
        let alert = AlertFactory().createAlert(title: ProductRegisterAlertText.failTitle.description,
                                               message: message.description,
                                               actions: okButton)
                
        present(alert, animated: true)
    }
}

// MARK: - ProductPlaceholder
enum ProductPlaceholder: String {
    case name = "상품명"
    case price = "상품가격"
    case discountedPrice = "할인금액"
    case stock = "재고수량"
    case description = "제품의 설명을 작성해주세요.\n글자수는 1000자 미만까지 가능합니다.\n\n\n\n\n"
    
    var text: String {
        return self.rawValue
    }
}

// MARK: - GenerateUserInputError
enum GenerateUserInputError: Error {
    case invalidNameCount
    case invalidDiscountedPrice
    case emptyPrice
    case invalidStock
    case invalidCurrency
    case invalidDescription
    
    var description: ProductRegisterAlertText {
        switch self {
        case .invalidNameCount:
            return ProductRegisterAlertText.nameFailMessage
        case .invalidDiscountedPrice:
            return ProductRegisterAlertText.discountedPriceFailMessage
        case .emptyPrice:
            return ProductRegisterAlertText.emptyPriceMessage
        case .invalidStock:
            return ProductRegisterAlertText.stockFailMessage
        case .invalidCurrency:
            return ProductRegisterAlertText.currencyFailMessage
        case .invalidDescription:
            return ProductRegisterAlertText.descriptionFailMessage
        }
    }
}

// MARK: - ProductRegisterImageActionSheetText
enum ProductRegisterImageActionSheetText: String {
    case addImageAlertTitle = "업로드할 사진을 선택해주세요"
    case editImageAlertTitle = "수정할 사진을 선택해주세요"
    case library = "앨범에서 가져오기"
    case camera = "사진 촬영"
    case cancel = "취소"
    case cameraDisableAlertTitle = "카메라를 사용할 수 없음"
    case confirm = "확인"
    
    var description: String {
        return self.rawValue
    }
}

// MARK: - ProductRegisterAlertText
enum ProductRegisterAlertText: String {
    case successTitle = "상품 등록이 완료되었습니다"
    case failTitle = "상품 등록에 실패했습니다"
    case imageFailMessage = "이미지는 최소 1장 이상 추가해주세요."
    case nameFailMessage = "상품명을 3글자 이상, 100글자 이하로 입력해주세요."
    case emptyPriceMessage = "상품가격을 입력해주세요."
    case discountedPriceFailMessage = "가격을 다시 확인해주세요."
    case stockFailMessage = "상품 수량을 0 이상으로 입력해주세요."
    case currencyFailMessage = "통화 단위를 다시 확인해주세요."
    case descriptionFailMessage = "상품 설명은 10글자 이상, 1000글자 이하로 작성해주세요."
    case confirm = "확인"
    
    var description: String {
        return self.rawValue
    }
}
