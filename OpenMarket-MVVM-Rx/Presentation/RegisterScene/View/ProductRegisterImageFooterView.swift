//
//  ProductRegisterImageFooterView.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/10.
//

import UIKit

final class ProductRegisterImageFooterView: UICollectionReusableView {
    private(set) var addButton = UIButton()
    
//    convenience init() {
//        self.init(frame: .zero)
//        configureUI()
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.backgroundColor = .lightGray

        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor),
            addButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.3),
        ])
    }
}
