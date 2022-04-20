import Foundation
import UIKit

struct OpenMarketBaseURL: BaseURLProtocol {
    var baseURL = "https://market-training.yagom-academy.kr/"
}

struct HealthCheckerAPI: Gettable {
    var url: URL?
    var method: HttpMethod = .get
    
    init(baseURL: BaseURLProtocol = OpenMarketBaseURL()) {
        self.url = URL(string: "\(baseURL.baseURL)healthChecker")
    }
}

struct ProductDetailAPI: Gettable {
    var url: URL?
    var method: HttpMethod = .get
    
    init(id: Int, baseURL: BaseURLProtocol = OpenMarketBaseURL()) {
        self.url = URL(string: "\(baseURL.baseURL)api/products/\(id)")
    }
}

struct ProductPageAPI: Gettable {
    var url: URL?
    var method: HttpMethod = .get
    
    init(pageNumber: Int, itemsPerPage: Int, baseURL: BaseURLProtocol = OpenMarketBaseURL()) {
        var urlComponents = URLComponents(string: "\(baseURL.baseURL)api/products?")
        let pageNumberQuery = URLQueryItem(name: "page_no", value: "\(pageNumber)")
        let itemsPerPageQuery = URLQueryItem(name: "items_per_page", value: "\(itemsPerPage)")
        urlComponents?.queryItems?.append(pageNumberQuery)
        urlComponents?.queryItems?.append(itemsPerPageQuery)
        
        self.url = urlComponents?.url
    }
}

struct ProductRegisterAPI: Postable {
    var url: URL?
    var method: HttpMethod = .post
    var identifier: String = "1061fe9a-7215-11ec-abfa-951effcf9a75"
    var contentType: String
    var body: Data?
    
    init(boundary: String, body: Data, baseURL: BaseURLProtocol = OpenMarketBaseURL()) {
        self.url = URL(string: "\(baseURL.baseURL)api/products")
        self.contentType = "multipart/form-data; boundary=\(boundary)"
        self.body = body
    }
}
