import SwiftUI

struct ClientInvoiceReport: Equatable {
    let id: UUID
    let client: ClientEntity
    let invoices: [InvoiceEntity]
    let name: String
    let currency: Currency
    var invoiceCount: Int { invoices.count }
    var totalAmount: Double {
        invoices.reduce(0) { $0 + $1.total }
    }
    var paidAmount: Double {
        invoices.filter(\.isPaid).reduce(0) { $0 + $1.total }
    }
    var unpaidAmount: Double {
        invoices.filter { !$0.isPaid }.reduce(0) { $0 + $1.total }
    }
}

extension ClientInvoiceReport {
    func detailViewModels() -> [InvoiceDetailViewModel] {
        invoices.map { invoice in
            InvoiceDetailViewModel(
                id: invoice.id ?? UUID(),
                invoiceNumber: invoice.invoiceNumber ?? "",
                dueDate: invoice.invoiceDate ?? Date(),
                currency: Currency(rawValue: invoice.currency ?? "") ?? .USD,
                total: invoice.total,
                isPaid: Binding<Bool>(
                    get: { invoice.isPaid },
                    set: { invoice.isPaid = $0 }
                )
            )
        }
    }
}
