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
    var total: String {
        let priceValue = Double(price) ?? 0
        let quantityValue = Double(quantity) ?? 0
        let subtotal = priceValue * quantityValue

        let discountValue = Double(discount) ?? 0
        let discountAmount: Double = {
            switch discountType {
            case .percentage:
                return subtotal * discountValue / 100
            case .flatAmount:
                return discountValue
            case .none:
                return 0
            }
        }()

        let taxableBase = subtotal - discountAmount

        let taxValue = Double(tax) ?? 0
        let taxAmount = taxableBase * taxValue / 100

        let totalValue = taxableBase + taxAmount

        return String(format: "%.2f", totalValue)
    }
}
