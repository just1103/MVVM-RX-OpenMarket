//
//  UserInputDataFactory.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/10.
//

import Foundation

struct UserInputToRegister {
    let name: String?
    let price: String?
    let discountPrice: String?
    let stock: String?
    let currencyIndex: Int
    let descriptionText: String?
}

struct UserInputDataFactory {
    static func create(_ userInput: UserInputToRegister) -> Result<ProductDetailToRegister, GenerateUserInputError> {
        let userInputChecker = UserInputChecker()
        guard let name = userInput.name,
              userInputChecker.checkName(name) else {
            return .failure(.invalidNameCount)
        }
        
        guard let priceText = userInput.price,
              let price = Double(priceText) else {
            return .failure(.emptyPrice)
        }
        
        var discountPrice: Double?
        if let discountPriceText = userInput.discountPrice,
           let discountPriceAsDouble = Double(discountPriceText) {
            discountPrice = discountPriceAsDouble
        } else {
            discountPrice = 0
        }
        
        guard let discountPrice = discountPrice,
              userInputChecker.checkDiscountedPrice(discountedPrice: discountPrice, price: price) else {
                  return .failure(.invalidDiscountedPrice)
              }
        
        var stock: Int?
        if let stockText = userInput.stock,
           let stockAsInt = Int(stockText) {
            if userInputChecker.checkStock(stockAsInt) {
                stock = stockAsInt
            } else {
                return .failure(.invalidStock)
            }
        }
        
        guard let descriptionText = userInput.descriptionText,
              userInputChecker.checkDescription(descriptionText) else {
            return .failure(.invalidDescription)
        }
        
        guard let currency = Currency.allCases[safe: userInput.currencyIndex] else {
            return .failure(.invalidCurrency)
        }
        
        let productDetailToRegister = ProductDetailToRegister(name: name,
                                                              descriptions: descriptionText,
                                                              price: price,
                                                              discountedPrice: discountPrice,
                                                              currency: currency,
                                                              stock: stock)
        
        return .success(productDetailToRegister)
    }
}
