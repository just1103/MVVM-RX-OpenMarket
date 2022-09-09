//
//  CoordinatorProtocol.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/09.
//

import UIKit

enum CoordinatorType {
    case list, detail
    case register, edit
}

protocol CoordinatorProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController? { get set }
    var type: CoordinatorType { get }
}
