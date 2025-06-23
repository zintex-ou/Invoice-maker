import Foundation

struct InvoiceInput {
    let id: UUID
    let client: ClientInput
    let number: String
    let invoiceDate: Date
    let dueDate: Date
    let currency: String
    let discount: Double
    let tax: Double
    var isPaid: Bool
    let total: Double
    let itemOrServices: [ItemServiceInput]
    let pdfFilePath: String
    let type: TemplateType
}
