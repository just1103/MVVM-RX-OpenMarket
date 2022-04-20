import Foundation

enum Currency: String, Codable {
    case krw = "KRW"
    case usd = "USD"
    
    var description: String {
        return rawValue
    }
}
