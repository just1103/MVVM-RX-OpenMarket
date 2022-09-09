//
//  ProductRegisterCoordinator.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/09.
//

import UIKit

protocol ProductInformationCoordinatorDelegate: AnyObject {
    func removeFromChildCoordinators(coordinator: CoordinatorProtocol)
}

final class ProductInformationCoordinator: CoordinatorProtocol {
    // MARK: - Properties
    weak var delegate: ProductDetailCoordinatorDelegate?
    weak var navigationController: UINavigationController?
    var childCoordinators = [CoordinatorProtocol]()
    var type: CoordinatorType = .register  // TODO: 상품상세화면 -> 수정화면 추가
    
    // MARK: - Initializers
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    func start() {
        showRegisterScene()
    }
    
    private func showRegisterScene() {
//        guard let navigationController = navigationController else { return }
//        
//        let productDetailViewModel = ProductDetailViewModel(coordinator: self)
//        let productDetailViewController = ProductDetailViewController(viewModel: productDetailViewModel)
//        productDetailViewModel.setupProductID(productID)
//        
//        navigationController.pushViewController(productDetailViewController, animated: true)
    }
    
//    func popCurrentPage(){  // ???: 구현 안해도 자동으로 Navigation이 pop시킴
//        navigationController?.popViewController(animated: true)
//    }
    
    func finish() {
        delegate?.removeFromChildCoordinators(coordinator: self)
    }
}
