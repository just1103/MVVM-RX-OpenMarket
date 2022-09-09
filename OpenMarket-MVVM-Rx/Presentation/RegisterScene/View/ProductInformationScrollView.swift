////
////  ProductInformationScrollView.swift
////  OpenMarket-MVVM-Rx
////
////  Created by Hyoju Son on 2022/09/09.
////
//
//import UIKit
//
//final class ProductInformationScrollView: UIScrollView {
//    // MARK: - Properties
//    private let containerStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.style(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 10)
//        let inset: CGFloat = 15
//        stackView.setupMargins(verticalInset: inset, horizontalInset: inset)
//        return stackView
//    }()
//    private(set) var imageCollectionView = ProductImageCollectionView(frame: CGRect.zero,
//                                                                      collectionViewLayout: UICollectionViewFlowLayout())
//    private(set) var nameTextField = RoundedRectTextField()
//    private let priceStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.style(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 8)
//        return stackView
//    }()
//    private(set) var priceTextField = RoundedRectTextField()
//    private(set) lazy var currencySegmentedControl: UISegmentedControl = {
//        let items = Currency.allCases.map { $0.description }
//        let segmentedControl = UISegmentedControl(items: items)
//        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
//        segmentedControl.selectedSegmentIndex = 0
//        segmentedControl.selectedSegmentTintColor = .white
//        segmentedControl.setTitleTextAttributes([.font: UIFont.preferredFont(forTextStyle: .body)], for: .normal)
//        segmentedControl.setTitleTextAttributes([.font: UIFont.preferredFont(forTextStyle: .headline)], for: .selected)
//        segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        return segmentedControl
//    }()
//    private(set) var discountedPriceTextField = RoundedRectTextField()
//    private(set) var stockTextField = RoundedRectTextField()
//    private(set) var descriptionTextView: UITextView = {
//        let textView = UITextView()
//        textView.textColor = UIColor.lightGray
//        textView.isScrollEnabled = false
//        textView.font = .preferredFont(forTextStyle: .body)
//        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
//        return textView
//    }()
//    
//    // MARK: - Initializers
//    convenience init() {
//        self.init(frame: .zero)
//        configureUI()
//    }
//    
//    // MARK: - Methods
//    private func configureUI() {
//        setupVerticalStackView()
//        setupImageCollectionView()
//        setupTextFields()
//        setupDescriptionTextView()
//    }
//    
////    private func setupVerticalStackView() {
////        addSubview(containerStackView)
////        containerStackView.addArrangedSubview(imageCollectionView)
////        containerStackView.addArrangedSubview(nameTextField)
////        priceStackView.addArrangedSubview(priceTextField)
////        priceStackView.addArrangedSubview(currencySegmentedControl)
////        containerStackView.addArrangedSubview(priceStackView)
////        containerStackView.addArrangedSubview(discountedPriceTextField)
////        containerStackView.addArrangedSubview(stockTextField)
////        containerStackView.addArrangedSubview(descriptionTextView)
////        
////        NSLayoutConstraint.activate([
////            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
////            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
////            containerStackView.topAnchor.constraint(equalTo: topAnchor),
////            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
////            imageCollectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.35),
////        ])
////    }
////    
////    private func setupImageCollectionView() {
////        let flowLayout = UICollectionViewFlowLayout()
////        flowLayout.scrollDirection = .horizontal
////        flowLayout.minimumLineSpacing = 14
////        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.width * 0.3)
////        imageCollectionView.collectionViewLayout = flowLayout
////        imageCollectionView.register(cellType: ProductImageCell.self)
////        imageCollectionView.register(reusableFooterViewType: ProductRegisterImageFooterView.self)
////        imageCollectionView.delegate = self
////    }
////    
////    private func setupTextFields() {
////        nameTextField.placeholder = ProductPlaceholder.name.text
////        priceTextField.placeholder = ProductPlaceholder.price.text
////        priceTextField.keyboardType = .decimalPad
////        discountedPriceTextField.placeholder = ProductPlaceholder.discountedPrice.text
////        discountedPriceTextField.keyboardType = .decimalPad
////        stockTextField.placeholder = ProductPlaceholder.stock.text
////        stockTextField.keyboardType = .decimalPad
////    }
////    
////    private func setupDescriptionTextView() {
////        descriptionTextView.text = ProductPlaceholder.description.text
////    }
//}
//
