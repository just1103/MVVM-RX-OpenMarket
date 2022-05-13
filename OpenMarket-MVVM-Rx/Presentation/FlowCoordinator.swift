import UIKit

struct FlowCoordinator {
    // MARK: - Properties
    weak private var navigationController: UINavigationController?
    private var productListViewController: ProductListViewController!
    private var productListViewModel: ProductListViewModel!
    private var menuSegmentedControl: MenuSegmentedControl!
    private var menuSegmentedControlViewModel: MenuSegmentedControlViewModel!
    
    // MARK: - Initializers
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    mutating func start() {
        let actions = ProductListViewModelAction(showProductDetail: showProductDetail)
        
        productListViewModel = ProductListViewModel(actions: actions)
        menuSegmentedControlViewModel = MenuSegmentedControlViewModel()
        menuSegmentedControl = MenuSegmentedControl(viewModel: menuSegmentedControlViewModel)
        productListViewController = ProductListViewController(viewModel: productListViewModel,
                                                              menuSegmentedControl: menuSegmentedControl)
        menuSegmentedControlViewModel.delegate = productListViewController

        navigationController?.pushViewController(productListViewController, animated: false)
    }
    
    func showProductDetail(with productID: Int) {
        let productDetailViewModel = ProductDetailViewModel()
        let productDetailViewController = ProductDetailViewController(viewModel: productDetailViewModel)
        productDetailViewModel.setupProductID(productID)
        
        navigationController?.pushViewController(productDetailViewController, animated: true)
    }
}
