import Foundation

enum JSONParserError: Error, LocalizedError {
    case decodingFail
    case encodingFail
    
    var errorDescription: String? {
        switch self {
        case .decodingFail:
            return "디코딩에 실패했습니다."
        case .encodingFail:
            return "인코딩에 실패했습니다."
        }
    }
}

struct JSONParser<Item: Codable> {
    func decode(from json: Data?) -> Result<Item, JSONParserError> {
        guard let data = json else {
            return .failure(.decodingFail)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(DateFormatter.shared)
        
        guard let decodedData = try? decoder.decode(Item.self, from: data) else {
            return .failure(.decodingFail)
        }
        
        return .success(decodedData)
    }
    
    func encode(from item: Item?) -> Result<Data, JSONParserError> {
        guard let item = item else {
            return .failure(.encodingFail)
        }
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(DateFormatter.shared)
        
        guard let encodedData = try? encoder.encode(item) else {
            return .failure(.encodingFail)
        }
        
        return .success(encodedData)
    }
}
