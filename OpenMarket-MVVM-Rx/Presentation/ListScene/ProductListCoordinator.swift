import UIKit

final class ProductListCoordinator: CoordinatorProtocol {
    // MARK: - Properties
    var navigationController: UINavigationController?
    var childCoordinators = [CoordinatorProtocol]()
    var type: CoordinatorType = .list
    
    // MARK: - Initializers
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    func start() {
        showListScene()
    }
    
    private func showListScene() {
        guard let navigationController = navigationController else { return }
        
        let productListViewModel = ProductListViewModel(coordinator: self)
        let underlinedMenuBarViewModel = UnderlinedMenuBarViewModel()
        let underlinedMenuBar = UnderlinedMenuBar(viewModel: underlinedMenuBarViewModel)
        let productListViewController = ProductListViewController(viewModel: productListViewModel,
                                                              underlinedMenuBar: underlinedMenuBar)
        productListViewModel.delegate = productListViewController
        underlinedMenuBarViewModel.delegate = productListViewController
        
        navigationController.pushViewController(productListViewController, animated: false)
    }
    
    func showProductDetailScene(with productID: Int) {
        guard let navigationController = navigationController else { return }
        let productDetailCoordinator = ProductDetailCoordinator(navigationController: navigationController)
        productDetailCoordinator.delegate = self
        childCoordinators.append(productDetailCoordinator)
        productDetailCoordinator.start(with: productID)
    }
}

extension ProductListCoordinator: ProductDetailCoordinatorDelegate {
    func removeFromChildCoordinators(coordinator: CoordinatorProtocol) {
        let updatedChildCoordinators = childCoordinators.filter { $0 !== coordinator }
        childCoordinators = updatedChildCoordinators
    }
}
