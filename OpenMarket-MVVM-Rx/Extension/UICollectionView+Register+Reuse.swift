//
//  UICollectionView+CellRegister+Reuse.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/09.
//

import UIKit

extension UICollectionView {
    // MARK: - Cell
    func register<T: UICollectionViewCell>(cellType: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            return T()
        }
        
        return cell
    }
    
    // MARK: - FooterView
    func register<T: UICollectionReusableView>(reusableFooterViewType: T.Type) {
        register(T.self, forSupplementaryViewOfKind: Self.elementKindSectionFooter, withReuseIdentifier: T.identifier)
    }
    
    // TODO: footer dequeue
}
