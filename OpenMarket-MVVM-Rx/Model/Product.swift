import Foundation

struct Product: Codable, Hashable {
    let id: Int // ServerAPI 특성상 id가 unique한 값으로 인식
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
