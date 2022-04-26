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
        let presentDetailObserver: Observable<Product>
    }
    
    // MARK: - Properties
    private var products: [Product]?
    private let disposeBag = DisposeBag()
    private var images: [UIImage]?
    
    // MARK: - Initializer
    init() {
        setupProducts(at: 1)
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let bannerObserver = PublishSubject<[UIImage]>()
        let presentDetailObserver = PublishSubject<Product>()
        
        configureViewDidLoadObserver(by: input, observer: bannerObserver)
        
        let output = Output(bannerObserver: bannerObserver.asObservable(),
                            presentDetailObserver: presentDetailObserver.asObservable())
        
        return output
    }
    
    private func setupProducts(at pageNumber: Int) {
        let networkProvider = NetworkProvider()
        networkProvider.fetchData(api: ProductPageAPI(pageNumber: pageNumber, itemsPerPage: 20),
                                  decodingType: ProductPage.self)
            .subscribe(onNext: { [weak self] productPage in
                self?.products = productPage.products
            })
            .disposed(by: disposeBag)
    }
    
    private func configureViewDidLoadObserver(by input: Input, observer: PublishSubject<[UIImage]>) {
        input.viewDidLoadObserver
            .subscribe(onNext: { [weak self] _ in
                self?.fetchBundleImages()
                guard let images = self?.images else { return }
                observer.onNext(images)
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
}
