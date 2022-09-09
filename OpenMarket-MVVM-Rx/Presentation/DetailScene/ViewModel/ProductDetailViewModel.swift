import Foundation
import RxSwift
import UIKit

class ProductDetailViewModel {
    // MARK: - Nested Types
    struct Input {
        let invokedViewDidLoad: Observable<Void>
//        let leftBarButtonDidTap: Observable<Void>?  // TODO: 이게 확장성이 더 좋을것 같은데
        let cellDidScroll: Observable<IndexPath>
    }
    
    struct Output {
        let product: Observable<DetailViewProduct>
    }
    
    // MARK: - Properties
    private weak var coordinator: ProductDetailCoordinator!
    private var productID: Int!
    private let disposeBag = DisposeBag()

    // MARK: - Initializers
    init(coordinator: ProductDetailCoordinator) {
        self.coordinator = coordinator
    }
    
    deinit {
        coordinator.finish()  // FIXME: 호출 안되는 문제
    }
    
    // MARK: - Methods
    func setupProductID(_ productID: Int) {
        self.productID = productID
    }
    
    func transform(_ input: Input) -> Output {
        let product = configureViewDidLoadObserver(by: input.invokedViewDidLoad)
//        configureLeftBarButtonDidTapObserver(by: input.leftBarButtonDidTap)
        
        let output = Output(product: product)
        
        return output
    }
    
    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>) -> Observable<DetailViewProduct> {
        return inputObserver
            .flatMap { [weak self] _ -> Observable<DetailViewProduct> in
                guard let self = self else { return Observable.just(DetailViewProduct()) }
                return self.fetchProduct(with: self.productID)
            }
    }
    
    private func fetchProduct(with id: Int) -> Observable<DetailViewProduct> {
        let networkProvider = NetworkProvider()
        let observable = networkProvider.fetchData(api: ProductDetailAPI(id: id), decodingType: DetailViewProduct.self)
        
        return observable
    }
    
//    private func configureLeftBarButtonDidTapObserver(by inputObserver: Observable<Void>?) {
//        inputObserver?
//            .subscribe(onNext: { [weak self] in
//                self?.coordinator.popCurrentPage()
//        })
//        .disposed(by: disposeBag)
//    }
}
