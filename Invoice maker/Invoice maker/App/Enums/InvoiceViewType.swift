enum InvoiceViewType {
    case createInvoice
    case createEstimate
    case editInvoice(InvoiceEntity)
    case editEstimate(InvoiceEntity)
    case convertEstimateToInvoice(InvoiceEntity)
}

