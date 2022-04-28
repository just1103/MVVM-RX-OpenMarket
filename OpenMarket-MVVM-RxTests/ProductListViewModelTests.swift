import XCTest
@testable import OpenMarket_MVVM_Rx

class ProductListViewModelTests: XCTestCase {
    var sut: ProductListViewModel!
    
    override func setUpWithError() throws {
        sut = ProductListViewModel()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_fetchBundleImages가_정상작동하는지() {
        guard let firstBannerImage = sut.test_fetchBundleImages() else {
            XCTFail()
            return
        }
        guard let firstBundleImage = UIImage(named: "image1.jpeg") else { return }
        XCTAssertEqual(firstBundleImage, firstBannerImage)
    }
    
    func test_setupProducts가_정상작동하는지() {
        let expectation = XCTestExpectation(description: "Request 비동기 테스트")
        guard let products = sut.test_fetchProducts() else {  // FIXME: fail
            XCTFail()
            return
        }
        let firstProductId = products[0].id
        let serverFirstProductId = 2018  // MARK: - Server에 데이터가 업데이트되면 테스트를 위해 값을 변경해야 함
        XCTAssertEqual(firstProductId, serverFirstProductId)
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 10.0)
    }
}
