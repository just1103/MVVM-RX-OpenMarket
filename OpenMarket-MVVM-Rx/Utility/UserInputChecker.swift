//
//  UserInputChecker.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/09.
//

import UIKit

struct UserInputChecker {
    func checkImage(_ images: [UIImage]) -> Bool {
        return images.count >= 1
    }
    
    func checkName(_ name: String) -> Bool {
        return  3...100 ~= name.count
    }
    
    func checkDiscountedPrice(discountedPrice: Double, price: Double) -> Bool {
        return price >= 0 && discountedPrice >= 0 && price >= discountedPrice
    }
    
    func checkStock(_ stock: Int) -> Bool {
        return stock >= 0
    }
        
    func checkDescription(_ description: String) -> Bool {
        return 10...1000 ~= description.count && (description == ProductPlaceholder.description.text) == false
    }
}
