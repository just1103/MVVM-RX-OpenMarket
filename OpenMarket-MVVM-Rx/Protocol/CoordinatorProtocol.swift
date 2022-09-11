//
//  CoordinatorProtocol.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/09.
//

import UIKit

enum CoordinatorType {  // 이걸 ViewModel
    case list, detail
    case productInformation(ProductInformationKind)
}

enum ProductInformationKind {
    case register, edit
}

protocol CoordinatorProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController? { get set }
    var type: CoordinatorType { get }
}
