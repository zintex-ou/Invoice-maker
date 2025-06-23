import Foundation

struct InvoiceTemplateModel {
    let id: UUID
    var header: InvoiceHeaderModel
    var summary: InvoiceSummaryModel
    var items: [InvoiceItemRowModel]
}
