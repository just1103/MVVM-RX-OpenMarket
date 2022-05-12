import Foundation
import RxSwift
import UIKit

class ProductListViewModel {
    enum Content {
        static let bannerCount = 5
    }
    
    struct Input {
        let invokedViewDidLoad: Observable<Void>
        let listRefreshButtonDidTap: Observable<Void>
        let cellDidScroll: Observable<IndexPath>
        let cellDidSelect: Observable<Int>
    }
    
    struct Output {
        let products: Observable<([UniqueProduct], [UniqueProduct])>
        let newProductDidPost: Observable<Void>
        let newPostedProducts: Observable<[UniqueProduct]>
        let nextPageProducts: Observable<[UniqueProduct]>
    }
    
    // MARK: - Properties
    private let actions: ProductListViewModelAction?
    private var currentProductsCount: Int = 20
    private var currentProductPage: Int = 1
    private var latestProductID: Int!
    private let disposeBag = DisposeBag()
    private var images: [UIImage]?
    
    // MARK: - Initializers
    init(actions: ProductListViewModelAction) {
        self.actions = actions
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let products = PublishSubject<([UniqueProduct], [UniqueProduct])>()
        let newProductDidPost = PublishSubject<Void>()
        let newPostedProducts = PublishSubject<[UniqueProduct]>()
        let nextPageProducts = PublishSubject<[UniqueProduct]>()
        
        configureViewDidLoadObserver(by: input.invokedViewDidLoad,
                                     productsOutput: products)
        configureViewDidLoadObserver(by: input.invokedViewDidLoad,
                                     newProductDidPostOutput: newProductDidPost)
        configureListRefreshButtonObserver(by: input.listRefreshButtonDidTap,
                                           outputObservable: newPostedProducts)
        configureCellDidScrollObserver(by: input.cellDidScroll,
                                       outputObservable: nextPageProducts)
        configureCellDidSelectObserver(by: input.cellDidSelect)

        let output = Output(products: products.asObservable(),
                            newProductDidPost: newProductDidPost.asObservable(),
                            newPostedProducts: newPostedProducts.asObservable(),
                            nextPageProducts: nextPageProducts.asObservable())
        
        return output
    }
    
    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>,
                                              productsOutput: PublishSubject<([UniqueProduct], [UniqueProduct])>) {
        inputObserver
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                _ = self.fetchProducts(at: 1, with: 20).subscribe(onNext: { productPage in  // FIXME: map은 안되고, subscribe은 됨(?)
                    let uniqueListProducts = self.makeHashable(from: productPage.products)
                    let recentBargainProducts = productPage.products.filter { product in
                        product.discountedPrice != 0
                    }
                    let bannerProducts = Array(recentBargainProducts[0..<Content.bannerCount])
                    let uniqueBannerProducts = self.makeHashable(from: bannerProducts)
                    
                    productsOutput.onNext((uniqueListProducts, uniqueBannerProducts))
                    guard let firstProductID = productPage.products.first?.id else { return }
                    self.latestProductID = firstProductID
                })
            })
            .disposed(by: disposeBag)
    }
    
    private func makeHashable(from products: [Product]) -> [UniqueProduct] {
        var uniqueProducts = [UniqueProduct]()
        products.forEach { product in
            let product = UniqueProduct(product: product)
            uniqueProducts.append(product)
        }
        return uniqueProducts
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
                                                    outputObservable: PublishSubject<[UniqueProduct]>) {
        inputObservable
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                _ = self.fetchProducts(at: 1, with: 20).subscribe(onNext: { productPage in  // FIXME: map은 안되고, subscribe은 됨(?)
                    let uniqueProducts = self.makeHashable(from: productPage.products)
                    outputObservable.onNext(uniqueProducts)
                    guard let firstProductID = productPage.products.first?.id else { return }
                    self.latestProductID = firstProductID
                    self.currentProductsCount = 20
                    self.currentProductPage = 1
                })
            })
            .disposed(by: disposeBag)
    }
    
    private func configureCellDidScrollObserver(by inputObservable: Observable<IndexPath>,
                                                outputObservable: PublishSubject<[UniqueProduct]>) {
        inputObservable
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if indexPath.row == self.currentProductsCount - 4 {
                    self.currentProductPage += 1
                    _ = self.fetchProducts(at: self.currentProductPage, with: 20).subscribe(onNext: { productPage in
                        self.currentProductsCount += 20
                        let uniqueProducts = self.makeHashable(from: productPage.products)
                        outputObservable.onNext(uniqueProducts)
                    })
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureCellDidSelectObserver(by inputObservable: Observable<Int>) {
        inputObservable
            .subscribe(onNext: { [weak self] productID in
                print(productID)
                self?.actions?.showProductDetail(productID)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 테스트코드
    @available(*, deprecated, message: "테스트에서만 호출할 코드입니다.")
    func test_fetchProducts() -> Observable<ProductPage> {
        return fetchProducts(at: 1, with: 20)
    }
}
