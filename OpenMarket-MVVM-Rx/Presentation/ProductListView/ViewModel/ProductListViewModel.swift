import Foundation
import RxSwift
import UIKit

class ProductListViewModel {
    struct Input {
        let invokedViewDidLoad: Observable<Void>
        let tableButtonDidTap: Observable<Void>
        let cellDidSelect: Observable<IndexPath>
    }
    
    struct Output {
        let bannerProducts: Observable<[Product]>
        let listProducts: Observable<[Product]>
        let selectedButton: Observable<Void>
        let selectedProduct: Observable<Product>
    }
    
    // MARK: - Properties
    var products: [Product]?
    private let disposeBag = DisposeBag()
    private var images: [UIImage]?
    
    // MARK: - Initializer
    init() {
//        fetchProducts(at: 1)
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let bannerProducts = PublishSubject<[Product]>()
        let listProducts = PublishSubject<[Product]>()
        let selectedButton = PublishSubject<Void>()
        let selectedProduct = PublishSubject<Product>()
        
        configureViewDidLoadObserver(by: input.invokedViewDidLoad,
                                     bannerProductsOutput: bannerProducts,
                                     listProductsOutput: listProducts)
        configureSelectedTableButtonObserver(by: input.tableButtonDidTap, output: selectedButton)
        
        let output = Output(bannerProducts: bannerProducts.asObservable(),
                            listProducts: listProducts.asObservable(),
                            selectedButton: selectedButton.asObservable(),
                            selectedProduct: selectedProduct.asObservable())
        
        return output
    }
    
    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>,
                                              bannerProductsOutput: PublishSubject<[Product]>,
                                              listProductsOutput: PublishSubject<[Product]>) {
        inputObserver
            .subscribe(onNext: { [weak self] _ in
                _ = self?.fetchProducts(at: 1).subscribe(onNext: { productPage in  // FIXME: map은 안되고, subscribe은 됨(?)
                    listProductsOutput.onNext(productPage.products)

                    let filteredProduct = productPage.products.filter { product in
                        product.discountedPrice != 0
                    }
                    bannerProductsOutput.onNext(Array(filteredProduct[0...2]))
                }) 
            })
            .disposed(by: disposeBag)
    }
    
    private func configureSelectedTableButtonObserver(by inputObserver: Observable<Void>, output: PublishSubject<Void>) {
        inputObserver
            .subscribe(onNext: { _ in
                output.onNext(())
            })
            .disposed(by: disposeBag)
    }
  
    private func fetchProducts(at pageNumber: Int) -> Observable<ProductPage> { // 이게 끝나면 View를 업데이트하도록 Rx 적용!
        let networkProvider = NetworkProvider()
        let observable = networkProvider.fetchData(api: ProductPageAPI(pageNumber: pageNumber, itemsPerPage: 20),
                                  decodingType: ProductPage.self)
        
        return observable
    }
    
    // MARK: - 테스트코드
    @available(*, deprecated, message: "테스트에서만 호출할 코드입니다.")
    func test_fetchProducts() -> Observable<ProductPage> {
        return fetchProducts(at: 1)
    }
}
