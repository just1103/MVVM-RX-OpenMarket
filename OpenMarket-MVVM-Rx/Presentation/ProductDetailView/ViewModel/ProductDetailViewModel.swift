import Foundation
import RxSwift
import UIKit

class ProductDetailViewModel {
    struct Input {
        let invokedViewDidLoad: Observable<Void>
    }
    
    struct Output {
        let product: Observable<DetailViewProduct>
        let productImages: Observable<[ProductImage]>
    }
    
    private var productID: Int!
    private let disposeBag = DisposeBag()
    
    func setupProductID(_ productID: Int) {
        self.productID = productID
    }
    
    func transform(_ input: Input) -> Output {
        let product = PublishSubject<DetailViewProduct>()
        let productImages = PublishSubject<[ProductImage]>()
        
        configureViewDidLoadObserver(by: input.invokedViewDidLoad,
                                     productOutput: product,
                                     productImages: productImages)
        
        let output = Output(product: product.asObservable(), productImages: productImages.asObservable())
        
        return output
    }
    
    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>,
                                              productOutput: PublishSubject<DetailViewProduct>,
                                              productImages: PublishSubject<[ProductImage]>) {
        inputObserver
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else { return }
                _ = self.fetchProduct(with: self.productID).subscribe(onNext: { productDetail in
                    productOutput.onNext(productDetail)
                    productImages.onNext(productDetail.images)
                })
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchProduct(with id: Int) -> Observable<DetailViewProduct> {
        let networkProvider = NetworkProvider()
        let observable = networkProvider.fetchData(api: ProductDetailAPI(id: id), decodingType: DetailViewProduct.self)
                                        
        return observable
    }
}
