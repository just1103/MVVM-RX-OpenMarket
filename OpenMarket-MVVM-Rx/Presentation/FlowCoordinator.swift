import UIKit

struct FlowCoordinator {
    weak private var navigationController: UINavigationController?
    private var productListViewController: ProductListViewController!
    private var productListViewModel: ProductListViewModel!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    mutating func start() {
        productListViewModel = ProductListViewModel()
        productListViewController = ProductListViewController(viewModel: productListViewModel)

        navigationController?.pushViewController(productListViewController, animated: false)
    }
}
