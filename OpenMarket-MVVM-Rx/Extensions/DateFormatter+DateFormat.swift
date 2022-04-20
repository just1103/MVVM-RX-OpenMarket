import Foundation

extension DateFormatter {
    static let shared: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .autoupdatingCurrent
        dateFormatter.locale = .autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
//        dateFormatter.dateStyle = .long // TODO: decoding 가능한지 테스트
        return dateFormatter
    }()
}
