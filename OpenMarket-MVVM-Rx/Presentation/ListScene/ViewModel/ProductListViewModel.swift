import RxSwift
import UIKit

final class ProductListViewModel {
    // MARK: - Nested Types
    struct Input {
        let invokedViewDidLoad: Observable<Void>
        let rightBarButtonDidTap: Observable<Void>?
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
    weak var delegate: ActivityIndicatorSwitchable!
    private weak var coordinator: ProductListCoordinator!
    private var currentProductsCount: Int = 20
    private var currentProductPage: Int = 1
    private var latestProductID: Int!
    private let disposeBag = DisposeBag()
    private var images: [UIImage]?
    
    // MARK: - Initializers
    init(coordinator: ProductListCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let products = configureViewDidLoadObserver(by: input.invokedViewDidLoad)
        let newProductDidPost = PublishSubject<Void>()
        let newPostedProducts = configureListRefreshButtonObserver(by: input.listRefreshButtonDidTap)
        let nextPageProducts = configureCellDidScrollObserver(by: input.cellDidScroll)
        
        configureViewDidLoadObserver(by: input.invokedViewDidLoad, newProductDidPostOutput: newProductDidPost)
        configureCellDidSelectObserver(by: input.cellDidSelect)
        configureRightBarButtonDidTapObserver(by: input.rightBarButtonDidTap)
        
        let output = Output(products: products,
                            newProductDidPost: newProductDidPost.asObservable(),
                            newPostedProducts: newPostedProducts,
                            nextPageProducts: nextPageProducts)
        
        return output
    }
    
    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>) -> Observable<([UniqueProduct], [UniqueProduct])> {
        return inputObserver
            .flatMap { [weak self] _ -> Observable<([UniqueProduct], [UniqueProduct])> in
                guard let self = self else { return Observable.just(([], [])) }
                self.delegate.showActivityIndicator()
                
                return self.fetchProducts(at: 1, with: 20).map { productPage -> ([UniqueProduct], [UniqueProduct]) in
                    let uniqueListProducts = self.makeHashable(from: productPage.products)
                    let recentBargainProducts = productPage.products.filter { product in
                        product.discountedPrice != 0
                    }
                    let bannerProducts = Array(recentBargainProducts[0..<Content.bannerCount])
                    let uniqueBannerProducts = self.makeHashable(from: bannerProducts)
                    guard let firstProductID = productPage.products.first?.id else { return ([], []) }
                    self.latestProductID = firstProductID
                    return (uniqueListProducts, uniqueBannerProducts)
                }
            }
    }
    
    private func makeHashable(from products: [Product]) -> [UniqueProduct] {
        var uniqueProducts = [UniqueProduct]()
        products.forEach { product in
            let product = UniqueProduct(product: product)
            uniqueProducts.append(product)
        }
        return uniqueProducts
    }
    
    private func fetchProducts(at pageNumber: Int, with itemsPerPage: Int) -> Observable<ProductPage> {
        let networkProvider = NetworkProvider()
        let observable = networkProvider.fetchData(
            api: ProductPageAPI(pageNumber: pageNumber, itemsPerPage: itemsPerPage),
            decodingType: ProductPage.self
        )
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
    
    private func configureListRefreshButtonObserver(by inputObservable: Observable<Void>) -> Observable<[UniqueProduct]> {
        inputObservable
            .flatMap { [weak self] _ -> Observable<[UniqueProduct]> in
                guard let self = self else { return Observable.just([]) }
                self.delegate.showActivityIndicator()
                
                return self.fetchProducts(at: 1, with: 20).map { productPage -> [UniqueProduct] in
                    guard let firstProductID = productPage.products.first?.id else { return [] }
                    self.latestProductID = firstProductID
                    self.currentProductsCount = 20
                    self.currentProductPage = 1
                    
                    return self.makeHashable(from: productPage.products)
                }
            }
    }
    
    private func configureCellDidScrollObserver(by inputObservable: Observable<IndexPath>) -> Observable<[UniqueProduct]> {
        return inputObservable
            .filter { [weak self] indexPath in
                return indexPath.row + 4 == self?.currentProductsCount
            }
            .flatMap { [weak self] _ -> Observable<[UniqueProduct]> in
                guard let self = self else { return Observable.just([]) }
                self.delegate.showActivityIndicator()
                
                self.currentProductPage += 1
                self.currentProductsCount += 20
                return self.fetchProducts(at: self.currentProductPage, with: 20).map { productPage -> [UniqueProduct] in
                    return self.makeHashable(from: productPage.products)
                }
            }
    }
    
    private func configureCellDidSelectObserver(by inputObservable: Observable<Int>) {
        inputObservable
            .subscribe(onNext: { [weak self] productID in
                self?.coordinator.showProductDetailScene(with: productID)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureRightBarButtonDidTapObserver(by inputObserver: Observable<Void>?) {
        inputObserver?
            .subscribe(onNext: { [weak self] in
                self?.coordinator.showProductRegisterScene()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - TestCodes
    @available(*, deprecated, message: "테스트에서만 호출할 코드입니다.")
    func test_fetchProducts() -> Observable<ProductPage> {
        return fetchProducts(at: 1, with: 20)
    }
}

// MARK: - NameSpaces
extension ProductListViewModel {
    private enum Content {
        static let bannerCount = 5
    }
}
