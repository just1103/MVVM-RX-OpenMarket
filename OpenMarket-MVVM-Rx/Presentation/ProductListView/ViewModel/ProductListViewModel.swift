import Foundation
import RxSwift
import UIKit

class ProductListViewModel {
    struct Input {
        let invokedViewDidLoad: Observable<Void>
        let cellDidSelect: Observable<IndexPath>
    }
    
    struct Output {
        let bannerProducts: Observable<[Product]>
        let listProducts: Observable<[Product]>
        let selectedProduct: Observable<Product>
    }
    
    // MARK: - Properties
    var products: [Product]?
    private let disposeBag = DisposeBag()
    private var images: [UIImage]?
    
    // MARK: - Initializer
    init() {
        fetchProducts(at: 1)
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let bannerProducts = PublishSubject<[Product]>()
        let listProducts = PublishSubject<[Product]>()
        let selectedProduct = PublishSubject<Product>()
        
//        configureViewDidLoadObserver(by: input.invokedViewDidLoad, outputObserver: bannerProducts)
        configureViewDidLoadObserver(by: input.invokedViewDidLoad, outputObserver: listProducts)
        
        // TODO: stream을 지속하기 위해 flatMap 사용
        let productsObservable = input.invokedViewDidLoad
            .flatMap {
                NetworkProvider().fetchData(api: ProductPageAPI(pageNumber: 1, itemsPerPage: 20),
                                            decodingType: ProductPage.self)
            }
            .map { $0.products }
        
        let output = Output(bannerProducts: bannerProducts.asObservable(),
                            listProducts: listProducts.asObservable(),
                            selectedProduct: selectedProduct.asObservable())
        
        return output
    }
    
//    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>, outputObserver: PublishSubject<[Product]>) {
//        inputObserver
//            .subscribe(onNext: { [weak self] _ in
//                let recentBargainProducts = self?.fetchProducts(at: 1).map { productPage in
//                    productPage.products.filter { product in
//                        product.discountedPrice != 0
//                    }
//                }
//                .take(3)
//                outputObserver =
//            })
//            .disposed(by: disposeBag)
//    }
    
    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>, listProductsOutput: PublishSubject<[Product]>, bannerProductsOutput: PublishSubject<[Product]>) {
        inputObserver
            .subscribe(onNext: { [weak self] _ in
                _ = self?.fetchProducts(at: 1).map { productPage in
                    listProductsOutput.onNext(productPage.products)
                    
                    let filteredProduct = productPage.products.filter { product in
                        product.discountedPrice != 0
                    }
                    bannerProductsOutput.onNext(Array(filteredProduct[0...2]))
                }
            })
            .disposed(by: disposeBag)
    }
  
    private func fetchProducts(at pageNumber: Int) -> Observable<ProductPage> { // 이게 끝나면 View를 업데이트하도록 Rx 적용!
        let networkProvider = NetworkProvider()
        let observable = networkProvider.fetchData(api: ProductPageAPI(pageNumber: pageNumber, itemsPerPage: 10),
                                  decodingType: ProductPage.self)
        
        return observable
//            _ = ob.subscribe(onNext: { [weak self] productPage in
//                self?.products = productPage.products
//                print("!!!")
//            })
//            .disposed(by: disposeBag)
    }
    
    // MARK: - 테스트코드
    @available(*, deprecated, message: "테스트에서만 호출할 코드입니다.")
    func test_fetchProducts() -> [Product]? {
        fetchProducts(at: 1)
        return products
    }
}
