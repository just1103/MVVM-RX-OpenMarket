//
//  RoundedRectTextField.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/09.
//

import UIKit

final class RoundedRectTextField: UITextField {
    // MARK: - Initializers
    convenience init() {
        self.init(frame: .zero)
        configureUI()
    }

    // MARK: - Methods
    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        borderStyle = .roundedRect
        font = .preferredFont(forTextStyle: .body)
    }
}
