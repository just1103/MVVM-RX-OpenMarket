//
//  Subscript+Safe.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/10.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
