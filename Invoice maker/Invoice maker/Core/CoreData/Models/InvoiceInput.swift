import Foundation

struct InvoiceInput {
    let client: ClientEntity
    let number: String
    let invoiceDate: Date
    let dueDate: Date
    let currency: String
    let discount: Double
    let tax: Double
    let isPaid: Bool
    let total: Double
    let itemOrServices: [ItemServiceInput]
}
