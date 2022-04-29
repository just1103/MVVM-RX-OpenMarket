import Foundation

struct UniqueProduct: Hashable {
    let product: Product
    let uuid = UUID()
}
