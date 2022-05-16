import Foundation

struct OpenMarketBaseURL: BaseURLProtocol {
    let baseURL = "https://market-training.yagom-academy.kr/"
}

struct ProductDetailAPI: Gettable {
    let url: URL?
    let method: HttpMethod = .get
    
    init(id: Int, baseURL: BaseURLProtocol = OpenMarketBaseURL()) {
        self.url = URL(string: "\(baseURL.baseURL)api/products/\(id)")
    }
}

struct ProductPageAPI: Gettable {
    let url: URL?
    let method: HttpMethod = .get
    
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
    let url: URL?
    let method: HttpMethod = .post
    let identifier: String = "1061fe9a-7215-11ec-abfa-951effcf9a75"
    let contentType: String
    let body: Data?
    
    init(boundary: String, body: Data, baseURL: BaseURLProtocol = OpenMarketBaseURL()) {
        self.url = URL(string: "\(baseURL.baseURL)api/products")
        self.contentType = "multipart/form-data; boundary=\(boundary)"
        self.body = body
    }
}
