//
//  DetailCoordinator.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/09.
//

import UIKit

protocol ProductDetailCoordinatorDelegate: AnyObject {
    func removeFromChildCoordinators(coordinator: CoordinatorProtocol)
}

final class ProductDetailCoordinator: CoordinatorProtocol {
    // MARK: - Properties
    weak var delegate: ProductDetailCoordinatorDelegate?
    weak var navigationController: UINavigationController?
    var childCoordinators = [CoordinatorProtocol]()
    var type: CoordinatorType = .detail
    
    // MARK: - Initializers
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    func start(with productID: Int) {
        showDetailScene(with: productID)
    }
    
    private func showDetailScene(with productID: Int) {
        guard let navigationController = navigationController else { return }
        
        let productDetailViewModel = ProductDetailViewModel(coordinator: self)
        let productDetailViewController = ProductDetailViewController(viewModel: productDetailViewModel)
        productDetailViewModel.setupProductID(productID)
        
        navigationController.pushViewController(productDetailViewController, animated: true)
    }
    
//    func popCurrentPage(){  // ???: 구현 안해도 자동으로 Navigation이 pop시킴
//        navigationController?.popViewController(animated: true)
//    }
    
    func finish() {
        delegate?.removeFromChildCoordinators(coordinator: self)
    }
}
