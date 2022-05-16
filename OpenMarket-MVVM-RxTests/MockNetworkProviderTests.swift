import XCTest
import RxSwift
@testable import OpenMarket_MVVM_Rx

class MockNetworkProviderTests: XCTestCase {
    let mockSession: URLSessionProtocol! = MockURLSession()
    var sut: NetworkProvider!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NetworkProvider(session: mockSession)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        disposeBag = nil
    }
    
    func test_getProductDetail가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "getProductDetail 비동기 테스트")

        let observable = sut.fetchData(api: ProductDetailAPI(id: 15), decodingType: Product.self)
        _ = observable.subscribe(onNext: { product in
            XCTAssertEqual(product.id, 15)
            XCTAssertEqual(product.name, "pizza")
            expectation.fulfill()
        })
        .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 10.0)
    }
}
