//
//  ProductRegisterViewModel.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/09.
//

import RxSwift
import UIKit

final class ProductInformationViewModel {
    // MARK: - Nested Types
    struct Input {
        let invokedViewDidLoad: Observable<Void>
        let leftBarButtonDidTap: Observable<Void>?
        let rightBarButtonDidTap: Observable<Void>?
    }
    
    struct Output {
//        let productDetail: Observable<UniqueProduct>
    }
    
    // MARK: - Properties
    private weak var coordinator: ProductInformationCoordinator!
    private let productInformationKind: ProductInformationKind!
    private var productDetail: UniqueProduct?
    private let disposeBag = DisposeBag()
    private(set) var productImages: [UIImage]?
    
    // MARK: - Initializers
    init(coordinator: ProductInformationCoordinator, kind: ProductInformationKind) {
        self.coordinator = coordinator
        self.productInformationKind = kind
    }
    
    deinit {
        coordinator.finish()
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
//        let products = configureViewDidLoadObserver(by: input.invokedViewDidLoad)
//        let newProductDidPost = PublishSubject<Void>()
//        let newPostedProducts = configureListRefreshButtonObserver(by: input.listRefreshButtonDidTap)
//        let nextPageProducts = configureCellDidScrollObserver(by: input.cellDidScroll)
//
        configureLeftBarButtonDidTapObserver(by: input.leftBarButtonDidTap)
        configureRightBarButtonDidTapObserver(by: input.rightBarButtonDidTap)
//        configureViewDidLoadObserver(by: input.invokedViewDidLoad, newProductDidPostOutput: newProductDidPost)
//        configureCellDidSelectObserver(by: input.cellDidSelect)
//
//        let output = Output(productDetail: Observable<UniqueProduct>)
        let output = Output()
        
        return output
    }
//
//    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>) -> Observable<([UniqueProduct], [UniqueProduct])> {
//        return inputObserver
//            .flatMap { [weak self] _ -> Observable<([UniqueProduct], [UniqueProduct])> in
//                guard let self = self else { return Observable.just(([], [])) }
//                self.delegate.showActivityIndicator()
//
//                return self.fetchProducts(at: 1, with: 20).map { productPage -> ([UniqueProduct], [UniqueProduct]) in
//                    let uniqueListProducts = self.makeHashable(from: productPage.products)
//                    let recentBargainProducts = productPage.products.filter { product in
//                        product.discountedPrice != 0
//                    }
//                    let bannerProducts = Array(recentBargainProducts[0..<Content.bannerCount])
//                    let uniqueBannerProducts = self.makeHashable(from: bannerProducts)
//                    guard let firstProductID = productPage.products.first?.id else { return ([], []) }
//                    self.latestProductID = firstProductID
//                    return (uniqueListProducts, uniqueBannerProducts)
//                }
//            }
//    }
//
//    private func makeHashable(from products: [Product]) -> [UniqueProduct] {
//        var uniqueProducts = [UniqueProduct]()
//        products.forEach { product in
//            let product = UniqueProduct(product: product)
//            uniqueProducts.append(product)
//        }
//        return uniqueProducts
//    }
//
//    private func fetchProducts(at pageNumber: Int, with itemsPerPage: Int) -> Observable<ProductPage> {
//        let networkProvider = NetworkProvider()
//        let observable = networkProvider.fetchData(
//            api: ProductPageAPI(pageNumber: pageNumber, itemsPerPage: itemsPerPage),
//            decodingType: ProductPage.self
//        )
//        return observable
//    }
//
//    private func configureViewDidLoadObserver(by inputObserver: Observable<Void>,
//                                              newProductDidPostOutput: PublishSubject<Void>) {
//        inputObserver
//            .subscribe(onNext: { [weak self] _ in
//                self?.autoCheckNewProductTimer(timeInterval: 10, newProductDidPostOutput: newProductDidPostOutput)
//            })
//            .disposed(by: disposeBag)
//    }
//
//    private func autoCheckNewProductTimer(timeInterval: TimeInterval = 10,
//                                          newProductDidPostOutput: PublishSubject<Void>) {
//        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
//            self?.checkNewProduct(newProductDidPostOutput: newProductDidPostOutput)
//        }
//    }
//
//    private func checkNewProduct(newProductDidPostOutput: PublishSubject<Void>) {
//        fetchProducts(at: 1, with: 1)
//            .subscribe(onNext: { [weak self] productPage in
//                guard let firstProductID = productPage.products.first?.id else { return }
//                if firstProductID != self?.latestProductID {
//                    newProductDidPostOutput.onNext(())
//                }
//            })
//            .disposed(by: disposeBag)
//    }
//
//    private func configureListRefreshButtonObserver(by inputObservable: Observable<Void>) -> Observable<[UniqueProduct]> {
//        inputObservable
//            .flatMap { [weak self] _ -> Observable<[UniqueProduct]> in
//                guard let self = self else { return Observable.just([]) }
//                self.delegate.showActivityIndicator()
//
//                return self.fetchProducts(at: 1, with: 20).map { productPage -> [UniqueProduct] in
//                    guard let firstProductID = productPage.products.first?.id else { return [] }
//                    self.latestProductID = firstProductID
//                    self.currentProductsCount = 20
//                    self.currentProductPage = 1
//
//                    return self.makeHashable(from: productPage.products)
//                }
//            }
//    }
//
//    private func configureCellDidScrollObserver(by inputObservable: Observable<IndexPath>) -> Observable<[UniqueProduct]> {
//        return inputObservable
//            .filter { [weak self] indexPath in
//                return indexPath.row + 4 == self?.currentProductsCount
//            }
//            .flatMap { [weak self] _ -> Observable<[UniqueProduct]> in
//                guard let self = self else { return Observable.just([]) }
//                self.delegate.showActivityIndicator()
//
//                self.currentProductPage += 1
//                self.currentProductsCount += 20
//                return self.fetchProducts(at: self.currentProductPage, with: 20).map { productPage -> [UniqueProduct] in
//                    return self.makeHashable(from: productPage.products)
//                }
//            }
//    }
//
//    private func configureCellDidSelectObserver(by inputObservable: Observable<Int>) {
//        inputObservable
//            .subscribe(onNext: { [weak self] productID in
//                self?.coordinator.showProductDetailScene(with: productID)
//            })
//            .disposed(by: disposeBag)
//    }
    
    private func configureLeftBarButtonDidTapObserver(by inputObserver: Observable<Void>?) {
        inputObserver?
            .subscribe(onNext: { [weak self] in
                self?.coordinator.popCurrentPage()
        })
        .disposed(by: disposeBag)
    }

    private func configureRightBarButtonDidTapObserver(by inputObserver: Observable<Void>?) {
        inputObserver?
            .subscribe(onNext: { [weak self] in

//                switch result {
//                case .success(let success):
//                    viewModel.
//                case .failure(let error):
        

        })
        .disposed(by: disposeBag)
    }

}
