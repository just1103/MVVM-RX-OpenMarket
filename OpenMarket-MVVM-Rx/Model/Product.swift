import Foundation

struct Product: Codable, Hashable {
    // TODO: 프로퍼티 앞에 private 붙여도 되는지 테스트
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
