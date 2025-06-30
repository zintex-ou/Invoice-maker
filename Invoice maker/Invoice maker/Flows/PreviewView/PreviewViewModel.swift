import Foundation
import MessageUI

@MainActor
final class PreviewViewModel: ObservableObject {
    @Published var shouldShowError: Bool = false
    @Published var isPaid: Bool
    @Published var popoverID: Int = 1
    
    private var invoiceEntity: InvoiceEntity
    private let dataBaseService = InvoiceDataBaseService.shared
    
    var pdfFilePath: URL
    var alert: AlertModel = .init(title: "", subtitle: "")
    var isWithStatusChange: Bool
    let isInvoice: Bool

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
    
    func deleteInvoice(completion: @escaping () -> Void) {
        Task {
            do {
                guard let id = invoiceEntity.id else { return }
                if isInvoice {
                    try await dataBaseService.deleteInvoice(with: id)
                } else {
                    try await dataBaseService.deleteEstimate(with: id)
                }
                completion()
            } catch {
                self.alert = .init(
                    title: "Failed to delete invoice",
                    subtitle: "An error occurred. Please try again later."
                )
                shouldShowError = true
            }
        }
    }
    
    func sendInvoice(completion: @escaping ((Bool) -> Void)) {
        do {
            let data = try Data(contentsOf: pdfFilePath)
            ContactSheet.shared.presentContactSheetWithPdf(pdfData: data, fileName: "Invoice.pdf", completion: { result in
                if result == .sent {
                    completion(true)
                    NotificationService.shared.post(event: .sentMailSuccessfully, object: true)
                }
            })
        } catch {
            self.alert = .init(
                title: "Failed to send invoice",
                subtitle: "An error occurred. Please try again later."
            )
            shouldShowError = true
        }
    }
}
