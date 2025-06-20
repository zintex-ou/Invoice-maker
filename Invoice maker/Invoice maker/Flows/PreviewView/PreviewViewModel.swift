import SwiftUI

final class PreviewViewModel: ObservableObject {
    var invoice: InvoiceTemplateModel
    var pdfFilePath: URL
    var type: TemplateType
    var alert: AlertModel = .init(title: "", subtitle: "")
    
    @Published var shouldShowError: Bool = false
    
    init(invoice: InvoiceTemplateModel, pdfFilePath: URL, type: TemplateType) {
        self.invoice = invoice
        self.pdfFilePath = pdfFilePath
        self.type = type
    }
    
    func deleteInvoice(completion: () -> Void) async {
        do {
            try await CoreDataManager.shared.deleteInvoice(byID: invoice.id)
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
