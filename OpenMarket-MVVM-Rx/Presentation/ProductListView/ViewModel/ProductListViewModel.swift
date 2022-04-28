import Foundation
import RxSwift
import UIKit

class ProductListViewModel {
    struct Input {
        let viewDidLoadObserver: Observable<Void>
        let cellPressedObserver: Observable<IndexPath>
    }
    
    struct Output {
        let bannerObserver: Observable<[UIImage]>
        let listObserver: Observable<[Product]>
        let presentDetailObserver: Observable<Product>
        let productsObserver: Observable<[Product]>
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
        let bannerObserver = PublishSubject<[UIImage]>()
        let listObserver = PublishSubject<[Product]>()
        let presentDetailObserver = PublishSubject<Product>()
        
        configureViewDidLoadObserver(by: input.viewDidLoadObserver, outputObserver: bannerObserver)
        configureViewDidLoadObserver(by: input.viewDidLoadObserver, outputObserver: listObserver)
        
        // TODO: stream을 지속하기 위해 flatMap 사용
        let productsObservable = input.viewDidLoadObserver
            .flatMap {
                NetworkProvider().fetchData(api: ProductPageAPI(pageNumber: 1, itemsPerPage: 20),
                                            decodingType: ProductPage.self)
            }
            .map { $0.products }
        
        let output = Output(bannerObserver: bannerObserver.asObservable(),
                            listObserver: listObserver.asObservable(),
                            presentDetailObserver: presentDetailObserver.asObservable(),
                            productsObserver: productsObservable)
        
        return output
    }
    
    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>, outputObserver: PublishSubject<[UIImage]>) {
        inputObserver
            .subscribe(onNext: { [weak self] _ in
                self?.fetchBundleImages()
                guard let images = self?.images else { return }
                outputObserver.onNext(images)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchBundleImages() {
        guard let firstImage = UIImage(named: "image1.jpeg"),
              let secondImage = UIImage(named: "image2.jpeg"),
              let thirdImage = UIImage(named: "image3.jpeg") else { return }
        let bannerImages = [firstImage, secondImage, thirdImage]
        
        images = bannerImages
    }
    
    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>, outputObserver: PublishSubject<[Product]>) {
        inputObserver
            .subscribe(onNext: { [weak self] _ in
                guard let products = self?.products else { return }
                outputObserver.onNext(products)
            })
            .disposed(by: disposeBag)
    }
  
    private func fetchProducts(at pageNumber: Int) { // 이게 끝나면 View를 업데이트하도록 Rx 적용!
        let networkProvider = NetworkProvider()
        let ob = networkProvider.fetchData(api: ProductPageAPI(pageNumber: pageNumber, itemsPerPage: 10),
                                  decodingType: ProductPage.self)
            _ = ob.subscribe(onNext: { [weak self] productPage in
                self?.products = productPage.products
                print("!!!")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 테스트코드
    @available(*, deprecated, message: "테스트에서만 호출할 코드입니다.")
    func test_fetchBundleImages() -> UIImage? {
        fetchBundleImages()
        guard let firstBannerImage = images?[0] else { return nil }
        return firstBannerImage
    }
    
    @available(*, deprecated, message: "테스트에서만 호출할 코드입니다.")
    func test_fetchProducts() -> [Product]? {
        fetchProducts(at: 1)
        return products
    }
}
