import SwiftUI

final class PreviewViewModel: ObservableObject {
    var invoice: InvoiceTemplateModel
    var pdfFilePath: URL
    var alert: AlertModel = .init(title: "", subtitle: "")
    var invoiceInput: InvoiceInput
    var isWithStatusChange: Bool
    private var invoiceEntity: InvoiceEntity
    
    @Published var shouldShowError: Bool = false
    @Published var isPaid: Bool = false
    @Published var isPaidPopShow = false
    @Published var popoverID: Int = 1
    
    init(
           invoiceInput: InvoiceInput,
           invoiceEntity: InvoiceEntity,
           pdfFilePath: URL,
           isWithStatusChange: Bool = false
       ) async {
           self.invoiceInput = invoiceInput
           self.invoiceEntity = invoiceEntity
           self.pdfFilePath = pdfFilePath
           self.isWithStatusChange = isWithStatusChange
           
           self.invoice = await invoiceEntity.toTemplateModel()
       }
    
    func dueDate() -> String {
        "Due date: \(invoice.header.invoiceInfo.dueDate)"
    }
    
    func total() -> String {
        "\(invoice.summary.currency.rawValue) \(invoice.summary.total)"
    }
    
    func updateInvoice() async {
        do {
            var input = invoiceInput
            input.isPaid = isPaid
            try await CoreDataManager.shared.updateInvoice(
                invoiceEntity,
                input: input
            )
        } catch {
            self.alert = .init(
                title: "Failed to update invoice",
                subtitle: "An error occurred. Please try again later."
            )
            shouldShowError = true
        }
    }
    
    func deleteInvoice(completion: () -> Void) async {
        do {
            try await CoreDataManager.shared.deleteInvoice(invoiceEntity)
            completion()
        } catch {
            self.alert = .init(
                title: "Failed to delete invoice",
                subtitle: "An error occurred. Please try again later."
            )
            shouldShowError = true
        }
    }
    
    func sendInvoice() {
        do {
            let data = try Data(contentsOf: pdfFilePath)
            ContactSheet.shared.presentContactSheetWithPdf(pdfData: data, fileName: "Invoice.pdf")
        } catch {
            self.alert = .init(
                title: "Failed to send invoice",
                subtitle: "An error occurred. Please try again later."
            )
            shouldShowError = true
        }
    }
}
