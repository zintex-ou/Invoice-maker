import SwiftUI

struct InvoiceDetailViewModel: Identifiable {
    let id: UUID
    let invoiceNumber: String
    let dueDate: Date
    let currency: Currency
    let total: Double
    let isPaid: Bool
}
