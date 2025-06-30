import Foundation

@MainActor
final class PreviewViewModel: ObservableObject {
    var pdfFilePath: URL
    var alert: AlertModel = .init(title: "", subtitle: "")
    var isWithStatusChange: Bool
    private var invoiceEntity: InvoiceEntity
    let isInvoice: Bool
    
    @Published var shouldShowError: Bool = false
    @Published var isPaid: Bool
    @Published var popoverID: Int = 1
    
    private let dataBaseService = InvoiceDataBaseService.shared
    
    init(
        invoiceEntity: InvoiceEntity,
        isWithStatusChange: Bool = false
    ) {
        self.invoiceEntity = invoiceEntity
        self.pdfFilePath = invoiceEntity.pdfFilePath ?? .currentDirectory()
        self.isWithStatusChange = isWithStatusChange
        self.isInvoice = invoiceEntity.isInvoice
        self.isPaid = invoiceEntity.isPaid
    }
    
    func title() -> String {
        isInvoice ? "Invoice" : "Estimate"
    }
    
    func buttonTitle() -> String {
        "Send \(title().lowercased())"
    }
    
    func name() -> String {
        invoiceEntity.client?.clientName ?? ""
    }
    
    func dueDate() -> String {
        "\(isInvoice ? "Due date" : "Estimate date"): \(invoiceEntity.dueDate?.formatedDateString ?? Date.now.formatedDateString)"
    }
    
    func total() -> String {
        "\(invoiceEntity.currency ?? "USD") \(invoiceEntity.total)"
    }
    
    func tapOnMenuButton(_ value: Bool) {
        isPaid = value
        
        Task {
            do {
                guard let id = invoiceEntity.id else { return }
                try await dataBaseService.change(isPaid: value, for: id)
            } catch {
                self.alert = .init(
                    title: "Failed to update invoice",
                    subtitle: "An error occurred. Please try again later."
                )
                shouldShowError = true
            }
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
