import Foundation

struct Product: Codable {
    // TODO: 프로퍼티 앞에 private 붙여도 되는지 테스트
    let id: Int
    let vendorId: Int
    let name: String
    let thumbnail: String
    let currency: Currency
    let price: Double
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let createdAt: Date
    let issuedAt: Date
}
