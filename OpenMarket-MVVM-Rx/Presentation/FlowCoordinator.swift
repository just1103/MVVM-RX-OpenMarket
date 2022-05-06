import UIKit

struct FlowCoordinator {
    weak private var navigationController: UINavigationController?
    private var productListViewController: ProductListViewController!
    private var productListViewModel: ProductListViewModel!
    private var menuSegmentedControl: MenuSegmentedControl!
    private var menuSegmentedControlViewModel: MenuSegmentedControlViewModel!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    mutating func start() {
        productListViewModel = ProductListViewModel()
        menuSegmentedControlViewModel = MenuSegmentedControlViewModel()
        menuSegmentedControl = MenuSegmentedControl(viewModel: menuSegmentedControlViewModel)
        productListViewController = ProductListViewController(viewModel: productListViewModel, menuSegmentedControl: menuSegmentedControl)
        menuSegmentedControlViewModel.delegate = productListViewController

        navigationController?.pushViewController(productListViewController, animated: false)
    }
}
