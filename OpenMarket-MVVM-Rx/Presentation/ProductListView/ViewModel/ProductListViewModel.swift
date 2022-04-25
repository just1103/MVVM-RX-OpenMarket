import Foundation
import RxSwift
import UIKit

class ProductListViewModel {
    struct Input {
        let cellPressedObserver: Observable<IndexPath>
    }
    
    struct Output {
        let presentDetailObserver: Observable<Product>
    }
    
    // MARK: - Properties
    private var products: [Product]?
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    init() {
        setupProducts(at: 1)
    }
    
    // MARK: - Methods
    private func setupProducts(at pageNumber: Int) {
        let networkProvider = NetworkProvider()
        networkProvider.fetchData(api: ProductPageAPI(pageNumber: pageNumber, itemsPerPage: 20),
                                  decodingType: ProductPage.self)
            .subscribe(onNext: { [weak self] productPage in
                self?.products = productPage.products
            })
            .disposed(by: disposeBag)
    }
}
