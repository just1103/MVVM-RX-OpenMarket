import XCTest
@testable import OpenMarket_MVVM_Rx

class NetworkProviderTests: XCTestCase {
    var sut: NetworkProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NetworkProvider()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }
    
    func test_getHealthChecker가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "getHealthChecker 비동기 테스트")
        
        let observableData = sut.request(api: HealthCheckerAPI())
        observableData.subscribe { data in
            data.map { data in
                let resultString = String(data: data, encoding: .utf8)
                let successString = #""OK""#
                XCTAssertEqual(resultString, successString)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }
    
//    func test_getProductDetail가_정상작동_하는지() {
//        let expectation = XCTestExpectation(description: "getProductDetail 비동기 테스트")
//
//        sut.request(api: ProductDetailAPI(id: 2)) { result in
//            switch result {
//            case .success(let data):
//                let product = try? JSONParser<Product>().decode(from: data).get()
//                XCTAssertEqual(product?.id, 2)
//                XCTAssertEqual(product?.name, "팥빙수")
//            case .failure(_):
//                XCTFail()
//            }
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 10.0)
//    }
//
//    func test_getProductPage가_정상작동_하는지() {
//        let expectation = XCTestExpectation(description: "getProductPage 비동기 테스트")
//
//        sut.request(api: ProductPageAPI(pageNumber: 1, itemsPerPage: 10)) { result in
//            switch result {
//            case .success(let data):
//                let productPage = try? JSONParser<ProductPage>().decode(from: data).get()
//                XCTAssertEqual(productPage?.pageNumber, 1)
//                XCTAssertEqual(productPage?.itemsPerPage, 10)
//            case .failure(_):
//                XCTFail()
//            }
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 10.0)
//    }
//
//    func test_URL이_유효하지않을때_statusCodeError가_나오는지() {
//        struct TestAPI: APIProtocol {
//            var url: URL? = URL(string: "www")
//            var method: HttpMethod = .get
//        }
//
//        sut.request(api: TestAPI()) { result in
//            switch result {
//            case .success(_):
//                XCTFail()
//            case .failure(let error):
//                XCTAssertEqual(error, .statusCodeError)
//            }
//        }
//    }
//
//    func test_URL이_Nil일때_invalidURLError가_나오는지() {
//        struct TestAPI: APIProtocol {
//            var url: URL?
//            var method: HttpMethod = .get
//        }
//
//        sut.request(api: TestAPI()) { result in
//            switch result {
//            case .success(_):
//                XCTFail()
//            case .failure(let error):
//                XCTAssertEqual(error, .urlIsNil)
//            }
//        }
//    }
//
//    func test_MockURLSession의_StatusCode가_200번일때_정상동작_하는지() {
//        let mockSession = MockURLSession(isRequestSuccess: true)
//        sut = NetworkDataTransfer(session: mockSession)
//
//        let expectation = XCTestExpectation(description: "MockURLSession의 getHealthChecker 비동기 테스트")
//
//        sut.request(api: HealthCheckerAPI()) { result in
//            switch result {
//            case .success(let data):
//                let resultString = String(data: data, encoding: .utf8)
//                let successString = #""OK""#
//                XCTAssertEqual(resultString, successString)
//            case .failure(_):
//                XCTFail()
//            }
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 10.0)
//    }
//
//    func test_MockURLSession의_StatusCode가_200번이_아닐때_실패하는지() {
//        let mockSession = MockURLSession(isRequestSuccess: false)
//        sut = NetworkDataTransfer(session: mockSession)
//
//        let expectation = XCTestExpectation(description: "MockURLSession의 getHealthChecker 비동기 테스트")
//
//        sut.request(api: HealthCheckerAPI()) { result in
//            switch result {
//            case .success(_):
//                XCTFail()
//            case .failure(let error):
//                XCTAssertEqual(error, NetworkError.statusCodeError)
//            }
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 10.0)
//    }
}
