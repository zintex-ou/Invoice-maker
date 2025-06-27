import SwiftUI

struct ChooseTemplateInvoiceModel {
    let client: ClientEntity
    let number: String
    let invoiceDate: Date
    let dueDate: Date
    let currency: String
    let discount: String
    let tax: String
    var subtotal: Double
    let total: Double
    let itemOrServices: [ItemServiceEntity]
}
