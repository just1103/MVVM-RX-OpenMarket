//
//  UICollectionReusableView+Identifier.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/10.
//

import UIKit

extension UICollectionReusableView {
    static var identifier: String {
        return String(describing: self)
    }
}
