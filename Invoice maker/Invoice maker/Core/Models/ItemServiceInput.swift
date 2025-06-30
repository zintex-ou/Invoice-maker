import Foundation

struct ItemServiceInput {
    let id: UUID
    var isItem: Bool
    var name: String
    var price: String
    var quantity: String
    var discountType: DiscountType
    var discount: String
    var tax: String
    var currency: Currency
    var total: String
}
