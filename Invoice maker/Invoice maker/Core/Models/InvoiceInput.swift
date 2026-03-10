import Foundation

struct InvoiceInput {
    let id: UUID
    let client: ClientEntity
    let number: String
    let invoiceDate: Date
    let dueDate: Date
    let freeField: String
    let currency: String
    let discount: String
    let tax: String
    var isPaid: Bool
    let total: Double
    let itemOrServices: [ItemServiceEntity]
    let pdfFilePath: URL
    let type: TemplateType
    let isInvoice: Bool
}
