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
    weak var delegate: ProductInformationCoordinatorDelegate?
    weak var navigationController: UINavigationController?
    var childCoordinators = [CoordinatorProtocol]()
    var type: CoordinatorType = .productInformation(.register)  // TODO: 상품상세화면 -> 수정화면 추가
    
    // MARK: - Initializers
    init(navigationController: UINavigationController, kind: ProductInformationKind) {
        self.navigationController = navigationController
        self.type = .productInformation(kind)
    }
    
    // MARK: - Methods
    func start() {
        showRegisterScene()
    }
    
    private func showRegisterScene() {
        guard let navigationController = navigationController else { return }
        let productInformationViewModel = ProductInformationViewModel(coordinator: self, kind: .register)
        let productInformationViewController = ProductInformationViewController(viewModel: productInformationViewModel)
        navigationController.pushViewController(productInformationViewController, animated: true)
    }
    
    private func showEditScene() {
        
    }
    
    func popCurrentPage(){
        navigationController?.popViewController(animated: true)
    }
    
    func finish() {
        delegate?.removeFromChildCoordinators(coordinator: self)
    }
}
