//
//  ProductImageCollectionView.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/09.
//

import UIKit

class ProductImageCollectionView: UICollectionView {
    var reloadDataCompletionHandler: (() -> Void)?
    
    func reloadDataCompletion(_ completion: @escaping () -> Void) {
        reloadDataCompletionHandler = completion
        super.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let handler = reloadDataCompletionHandler {
            handler()
            reloadDataCompletionHandler = nil
        }
    }
}
