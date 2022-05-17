import Foundation
import RxSwift
import UIKit

class ProductDetailViewModel {
    // MARK: - Nested Types
    struct Input {
        let invokedViewDidLoad: Observable<Void>
        let cellDidScroll: Observable<IndexPath>
    }
    
    struct Output {
        let product: Observable<DetailViewProduct>
    }
    
    // MARK: - Properties
    private var productID: Int!
    private let disposeBag = DisposeBag()
    
    // MARK: - Methods
    func setupProductID(_ productID: Int) {
        self.productID = productID
    }
    
    func transform(_ input: Input) -> Output {
        let product = configureViewDidLoadObserver(by: input.invokedViewDidLoad)
        
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
}
