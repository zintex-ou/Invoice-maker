import Foundation

struct InvoiceItemRowModel: Identifiable {
    let id = UUID()
    var name: String
    var pricePerUnit: String
    var quantity: String
    var discountPercentage: String
    var taxPercentage: String
    var total: String
}
