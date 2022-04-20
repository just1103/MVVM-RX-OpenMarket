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
            
            return Disposables.create()
        }
    }
    
    
}
