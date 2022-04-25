import Foundation

struct Product: Codable, Hashable {
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
    
    // TODO: 메서드 없어도 가능한지 테스트. 컴파일 에러가 발생하지 않음
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}
