import Foundation

struct InvoiceItemRowModel: Identifiable {
    let id = UUID()
    var name: String
    var pricePerUnit: Double
    var quantity: Double
    var discountPercentage: Double
    var taxPercentage: Double
    
    var total: Double {
        let base = pricePerUnit * quantity
        let discounted = base * (1 - discountPercentage / 100)
        let taxed = discounted * (1 + taxPercentage / 100)
        return taxed
    }
}
