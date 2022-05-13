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
    
    func test_getHealthChecker가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "getHealthChecker 비동기 테스트")
        
        let observableData = sut.request(api: HealthCheckerAPI())
        _ = observableData.subscribe(onNext: { data in
            let resultString = String(data: data, encoding: .utf8)
            let successString = #""OK""#
            XCTAssertEqual(resultString, successString)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func test_getHealthChecker가_정상실패_하는지() {
        let expectation = XCTestExpectation(description: "getHealthChecker 비동기 테스트")
        
        sut = NetworkProvider(session: MockURLSession(isRequestSuccess: false))
        
        let observableData = sut.request(api: HealthCheckerAPI())
        _ = observableData.subscribe(onError: { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.statusCodeError)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func test_getHealthChecker가_오류를_정상반환_하는지() {
        let expectation = XCTestExpectation(description: "getHealthChecker 비동기 테스트")
        
        var healthCheckerAPI = HealthCheckerAPI()
        healthCheckerAPI.url = URL(string: "wrongURL")
        
        let observableData = sut.request(api: healthCheckerAPI)
        _ = observableData
            .debug()
            .subscribe(onNext: { _ in
                print("!!!!")
                expectation.fulfill()
                
            }, onError: { error in
                XCTAssertEqual(error as? NetworkError, NetworkError.statusCodeError)
                expectation.fulfill()
            }
            )
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10)
    }
  
    // 서버 용량 제한으로 해당 id가 자동 삭제되어 테스트 Fail 발생 가능
    func test_getProductDetail가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "getProductDetail 비동기 테스트")

        let observable = sut.request(api: ProductDetailAPI(id: 600))
        _ = observable.subscribe(onNext: { data in
            let product = JSONParser<Product>().decode(from: data)
            XCTAssertEqual(product?.id, 600)
            XCTAssertEqual(product?.name, "Test Product")
            expectation.fulfill()
        })
        .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_getProductPage가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "getProductPage 비동기 테스트")

        let observableData = sut.request(api: ProductPageAPI(pageNumber: 1, itemsPerPage: 10))
        _ = observableData.subscribe(onNext: { data in
            let productPage = JSONParser<ProductPage>().decode(from: data)
            XCTAssertEqual(productPage?.pageNumber, 1)
            XCTAssertEqual(productPage?.itemsPerPage, 10)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_URL이_유효하지않을때_statusCodeError가_나오는지() {
        let expectation = XCTestExpectation(description: "Request 비동기 테스트")
        
        struct TestAPI: APIProtocol {
            var url: URL? = URL(string: "wrongURL")
            var method: HttpMethod = .get
        }

        let observableData = sut.request(api: TestAPI())
        _ = observableData.subscribe(onError: { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.statusCodeError)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_URL이_Nil일때_urlIsNil_Error가_나오는지() {
        let expectation = XCTestExpectation(description: "Request 비동기 테스트")
        
        struct TestAPI: APIProtocol {
            var url: URL?
            var method: HttpMethod = .get
        }

        let observableData = sut.request(api: TestAPI())
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
            XCTAssertEqual(productPage.products[0].id, 2093)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 20.0)
    }
}
