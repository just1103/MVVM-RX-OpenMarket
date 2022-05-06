import Foundation
import RxSwift
import UIKit

class ProductListViewModel {
    struct Input {
        let invokedViewDidLoad: Observable<Void>
        let listRefreshButtonDidTap: Observable<Void> // fetch 다시, 맨위로 scroll, button 숨기기
        //        let cellDidSelect: Observable<IndexPath>
    }
    
    struct Output {
        let listProducts: Observable<[Product]>
        let newProductDidPost: Observable<Void>
        let newListProducts: Observable<[Product]>
        //        let selectedProduct: Observable<Product>
    }
    
    // MARK: - Properties
    var products: [Product]?
    var latestProductID: Int!
    private let disposeBag = DisposeBag()
    private var images: [UIImage]?
    
    // MARK: - Initializer
    init() {
        
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let listProducts = PublishSubject<[Product]>()
        let newProductDidPost = PublishSubject<Void>()
        let newListProducts = PublishSubject<[Product]>()
        //        let selectedProduct = PublishSubject<Product>()
        
        configureViewDidLoadObserver(by: input.invokedViewDidLoad,
                                     listProductsOutput: listProducts)
        configureViewDidLoadObserver(by: input.invokedViewDidLoad,
                                     newProductDidPostOutput: newProductDidPost)
        configureListRefreshButtonObserver(by: input.listRefreshButtonDidTap,
                                           outputObservable: newListProducts)
        
        let output = Output(listProducts: listProducts.asObservable(),
                            newProductDidPost: newProductDidPost.asObservable(),
                            newListProducts: newListProducts.asObservable())
        
        return output
    }
    
    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>,
                                              listProductsOutput: PublishSubject<[Product]>) {
        inputObserver
            .subscribe(onNext: { [weak self] _ in
                _ = self?.fetchProducts(at: 1, with: 20).subscribe(onNext: { productPage in  // FIXME: map은 안되고, subscribe은 됨(?)
                    listProductsOutput.onNext(productPage.products)
                    guard let firstProductID = productPage.products.first?.id else { return }
                    self?.latestProductID = firstProductID
                })
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchProducts(at pageNumber: Int, with itemsPerPage: Int) -> Observable<ProductPage> { // 이게 끝나면 View를 업데이트하도록 Rx 적용!
        let networkProvider = NetworkProvider()
        let observable = networkProvider.fetchData(api: ProductPageAPI(pageNumber: pageNumber, itemsPerPage: itemsPerPage),
                                                   decodingType: ProductPage.self)
        return observable
    }
    
    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>,
                                              newProductDidPostOutput: PublishSubject<Void>) {
        inputObserver
            .subscribe(onNext: { [weak self] _ in
                self?.autoCheckNewProductTimer(timeInterval: 10, newProductDidPostOutput: newProductDidPostOutput)
            })
            .disposed(by: disposeBag)
    }
    
    private func autoCheckNewProductTimer(timeInterval: TimeInterval = 10,
                                          newProductDidPostOutput: PublishSubject<Void>) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
            self?.checkNewProduct(newProductDidPostOutput: newProductDidPostOutput)
        }
    }
    
    private func checkNewProduct(newProductDidPostOutput: PublishSubject<Void>) {
        fetchProducts(at: 1, with: 1)
            .subscribe(onNext: { [weak self] productPage in
                guard let firstProductID = productPage.products.first?.id else { return }
                if firstProductID != self?.latestProductID {
                    newProductDidPostOutput.onNext(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureListRefreshButtonObserver(by inputObservable: Observable<Void>,
                                                    outputObservable: PublishSubject<[Product]>) {
        inputObservable
            .subscribe(onNext: { [weak self] _ in
                _ = self?.fetchProducts(at: 1, with: 20).subscribe(onNext: { productPage in  // FIXME: map은 안되고, subscribe은 됨(?)
                    outputObservable.onNext(productPage.products)
                    guard let firstProductID = productPage.products.first?.id else { return }
                    self?.latestProductID = firstProductID
                })
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 테스트코드
    @available(*, deprecated, message: "테스트에서만 호출할 코드입니다.")
    func test_fetchProducts() -> Observable<ProductPage> {
        return fetchProducts(at: 1, with: 20)
    }
}
