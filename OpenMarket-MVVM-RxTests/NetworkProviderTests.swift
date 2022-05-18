import XCTest
import RxSwift
@testable import OpenMarket_MVVM_Rx

class NetworkProviderTests: XCTestCase {
    var sut: NetworkProvider!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NetworkProvider()
        disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        disposeBag = nil
    }
    
    // 서버 용량 제한으로 해당 id가 자동 삭제되어 테스트 Fail 발생 가능
    func test_getProductDetail가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "getProductDetail 비동기 테스트")
        
        let observable = sut.fetchData(api: ProductDetailAPI(id: 600), decodingType: Product.self)
        _ = observable.subscribe(onNext: { product in
            XCTAssertEqual(product.id, 600)
            XCTAssertEqual(product.name, "Test Product")
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_getProductPage가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "getProductPage 비동기 테스트")
        
        let observableData = sut.fetchData(api: ProductPageAPI(pageNumber: 1, itemsPerPage: 10), decodingType: ProductPage.self)
        _ = observableData.subscribe(onNext: { productPage in
            XCTAssertEqual(productPage.pageNumber, 1)
            XCTAssertEqual(productPage.itemsPerPage, 10)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_URL이_유효하지않을때_statusCodeError가_나오는지() {
        let expectation = XCTestExpectation(description: "Request 비동기 테스트")
        
        struct TestAPI: Gettable {
            var url: URL? = URL(string: "wrongURL")
            var method: HttpMethod = .get
        }
        
        let observableData = sut.fetchData(api: TestAPI(), decodingType: ProductPage.self)
        _ = observableData.subscribe(onError: { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.statusCodeError)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_URL이_Nil일때_urlIsNil_Error가_나오는지() {
        let expectation = XCTestExpectation(description: "Request 비동기 테스트")
        
        struct TestAPI: Gettable {
            var url: URL?
            var method: HttpMethod = .get
        }
        
        let observableData = sut.fetchData(api: TestAPI(), decodingType: ProductPage.self)
        _ = observableData.subscribe(onError: { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.urlIsNil)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // 첫번째 프로덕트가 갱신될 수 있어 테스트 Fail 발생 가능
    func test_fetchData가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "getProductPage 비동기 테스트")
        
        let observableData = sut.fetchData(api: ProductPageAPI(pageNumber: 1, itemsPerPage: 10),
                                           decodingType: ProductPage.self)
        _ = observableData.subscribe(onNext: { productPage in
            XCTAssertEqual(productPage.pageNumber, 1)
            XCTAssertEqual(productPage.itemsPerPage, 10)
            XCTAssertEqual(productPage.products[0].id, 2094)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 20.0)
    }
}
