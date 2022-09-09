import Foundation

enum Currency: String, Codable, CaseIterable {
    case krw = "KRW"
    case usd = "USD"
    
    var description: String {
        return rawValue
    }
}
