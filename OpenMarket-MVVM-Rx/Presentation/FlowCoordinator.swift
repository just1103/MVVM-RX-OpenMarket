import UIKit

final class FlowCoordinator {
    // MARK: - Properties
    weak private var navigationController: UINavigationController?
    private var productListViewController: ProductListViewController!
    private var productListViewModel: ProductListViewModel!
    private var underlinedMenuBar: UnderlinedMenuBar!
    private var underlinedMenuBarViewModel: UnderlinedMenuBarViewModel!
    
    // MARK: - Initializers
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    func start() {
        let actions = ProductListViewModelAction(showProductDetail: showProductDetail)
        
        productListViewModel = ProductListViewModel(actions: actions)
        underlinedMenuBarViewModel = UnderlinedMenuBarViewModel()
        underlinedMenuBar = UnderlinedMenuBar(viewModel: underlinedMenuBarViewModel)
        productListViewController = ProductListViewController(viewModel: productListViewModel,
                                                              underlinedMenuBar: underlinedMenuBar)
        underlinedMenuBarViewModel.delegate = productListViewController
        
        navigationController?.pushViewController(productListViewController, animated: false)
    }
    
    func showProductDetail(with productID: Int) {
        let productDetailViewModel = ProductDetailViewModel()
        let productDetailViewController = ProductDetailViewController(viewModel: productDetailViewModel)
        productDetailViewModel.setupProductID(productID)
        
        navigationController?.pushViewController(productDetailViewController, animated: true)
    }
}
