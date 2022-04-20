import Foundation

struct ProductImage: Codable {
    let id: Int
    let url: String
    let thumbnailUrl: String
    let isUploadSucceed: Bool
    let issuedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, url, thumbnailUrl, issuedAt
        
        case isUploadSucceed = "succeed"
    }
}
