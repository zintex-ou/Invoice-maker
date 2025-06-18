struct InvoiceTemplateModel {
    var header: InvoiceHeaderModel
    var summary: InvoiceSummaryModel
    var items: [InvoiceItemRowModel]
}
