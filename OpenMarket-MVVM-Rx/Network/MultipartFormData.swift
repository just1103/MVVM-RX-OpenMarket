import UIKit

struct MultipartFormData {
    private(set) var boundary: String
    let contentType: String
    private(set) var body: Data = Data()
    
    init(uuid: String = UUID().uuidString) {
        self.boundary = "Boundary-\(uuid)"
        self.contentType = "multipart/form-data; boundary=\(self.boundary)"
    }
    
    mutating func appendToBody(from data: Data) {
        self.body.append(data)
    }
      
    func createFormData<Item: Codable>(params: String, item: Item) -> Data {
        var data = Data()
        data.append(BoundaryGenerator.boundaryData(forBoundaryType: .startSymbol, boundary: boundary))
        data.append(ContentDisposition.formData(params: params).bodyComponent)
        
        let encodedResult = JSONParser<Item>().encode(from: item)
        switch encodedResult {
        case .success(let encodedData):
            data.append(encodedData)
        case .failure(let error):
            print(error.localizedDescription)
        }
        data.append(BoundaryGenerator.boundaryData(forBoundaryType: .endSymbol, boundary: boundary))
        
        return data
    }
    
    func createImageFormData(name: String, fileName: String, contentType: ImageContentType, image: UIImage) -> Data {
        var data = Data()
        data.append(BoundaryGenerator.boundaryData(forBoundaryType: .startSymbol, boundary: boundary))
        data.append(ContentDisposition.imageFormData(name: name, filename: fileName).bodyComponent)
        data.append(ContentDisposition.imageContentType(type: contentType).bodyComponent)
        
        switch contentType {
        case .png:
            if let imageData = image.pngData() {
                data.append(imageData)
            }
        case .jpeg:
            if let imageData = image.jpegData(compressionQuality: 1) {
                data.append(imageData)
            }
        }
        data.append(BoundaryGenerator.boundaryData(forBoundaryType: .endSymbol, boundary: boundary))
        
        return data
    }
    
    mutating func closeBody() {
        self.body.append(BoundaryGenerator.boundaryData(forBoundaryType: .terminator, boundary: boundary))
    }
}

enum ImageContentType: String, CustomStringConvertible {
    case png
    case jpeg
    
    var description: String {
        return "image/\(rawValue)"
    }
}

enum ContentDisposition {
    case formData(params: String)
    case imageFormData(name: String, filename: String)
    case imageContentType(type: ImageContentType)
    
    var bodyComponent: String {
        switch self {
        case .formData(let params):
            return "Content-Disposition: form-data; name=\"\(params)\""
                    + EncodingCharacters.doubleNewLine
        case .imageFormData(let name, let filename):
            return "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\""
                    + EncodingCharacters.newLine
        case .imageContentType(let type):
            return "Content-Type: \(type.description)" + EncodingCharacters.doubleNewLine
        }
    }
}

enum EncodingCharacters {
    static let newLine = "\r\n"
    static let doubleNewLine = "\r\n\r\n"
}

enum BoundaryGenerator {
    enum BoundaryType {
        case startSymbol, endSymbol, terminator
    }
    
    static func boundaryData(forBoundaryType boundaryType: BoundaryType, boundary: String) -> Data {
        let boundaryText: String
        
        switch boundaryType {
        case .startSymbol:
            boundaryText = "--\(boundary)\(EncodingCharacters.newLine)"
        case .endSymbol:
            boundaryText = "\(EncodingCharacters.newLine)"
        case .terminator:
            boundaryText = "--\(boundary)--"
        }
        
        return Data(boundaryText.utf8)
    }
}

private extension Data {
    mutating func append(_ string: String?) {
        if let stringData = string?.data(using: .utf8) {
            self.append(stringData)
        }
    }
}
