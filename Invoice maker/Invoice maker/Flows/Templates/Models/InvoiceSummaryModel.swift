struct InvoiceSummaryModel {
    var currency: Currency
    var subtotal: Double
    var discountPercentage: Double?
    var taxPercentage: Double?
    
    var total: Double {
        let discount = discountPercentage ?? 0
        let tax = taxPercentage ?? 0
        
        let discountedAmount = subtotal * (1 - discount / 100)
        let taxedAmount = discountedAmount * (1 + tax / 100)
        return taxedAmount
    }
}
