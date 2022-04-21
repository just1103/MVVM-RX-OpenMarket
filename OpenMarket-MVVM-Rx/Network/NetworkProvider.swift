import Foundation
import RxSwift

enum NetworkError: Error, LocalizedError {
    case statusCodeError
    case unknownError
    case urlIsNil
    
    var errorDescription: String? {
        switch self {
        case .statusCodeError:
            return "정상적인 StatusCode가 아닙니다."
        case .unknownError:
            return "알수 없는 에러가 발생했습니다."
        case .urlIsNil:
            return "정상적인 URL이 아닙니다."
        }
    }
}

struct NetworkProvider {
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    private func loadData(request: URLRequest) -> Observable<Data> {
        return Observable.create { emitter in
            let task = session.dataTask(with: request) { data, response, _ in
                let successStatusCode = 200..<300
                guard let httpResponse = response as? HTTPURLResponse,
                      successStatusCode.contains(httpResponse.statusCode) else {
                          emitter.onError(NetworkError.statusCodeError)
                          return
                      }
                
                if let data = data {
                    emitter.onNext(data)
                }
                
                emitter.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func request(api: APIProtocol) -> Observable<Data> {
        return Observable.create { emitter in
            guard let urlRequest = URLRequest(api: api) else {
                emitter.onError(NetworkError.urlIsNil)
                return Disposables.create()
            }
            
            _ = loadData(request: urlRequest)
                .map { emitter.onNext($0) }
            
            emitter.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func fetchData<T: Codable>(api: Gettable, decodingType: T.Type) -> Observable<T> {
        return Observable.create { emitter in
            let result = request(api: api)
            _ = result.map {
                let decodedData = JSONParser<T>().decode(from: $0)
                switch decodedData {
                case .success(let data):
                    emitter.onNext(data)
                    emitter.onCompleted()
                case .failure:
                    emitter.onError(JSONParserError.decodingFail)
                }
            }
            
            return Disposables.create()
        }
    }
}
