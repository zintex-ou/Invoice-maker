import Foundation
import MessageUI

@MainActor
final class PreviewViewModel: ObservableObject {
    @Published var shouldShowError: Bool = false
    @Published var isPaid: Bool
    @Published var popoverID: Int = 1
    @Published var isShowDeleteAlert = false
    
    private(set) var invoiceEntity: InvoiceEntity
    private let dataBaseService = InvoiceDataBaseService.shared
    private let fileManagerPDFService = FileManagerPDFService()
    private(set) var pdfFilePath: URL
    private(set) var isInvoice: Bool
    
    var alert: AlertModel = .init(title: "", subtitle: "")

    init(
        invoiceEntity: InvoiceEntity
    ) {
        self.invoiceEntity = invoiceEntity
        self.isInvoice = invoiceEntity.isInvoice
        self.isPaid = invoiceEntity.isPaid
        
        let type: InvoiceType = invoiceEntity.isInvoice ? .invoice : .estimate
        self.pdfFilePath = fileManagerPDFService.resolvePDFURL(
            storedURL: invoiceEntity.pdfFilePath,
            for: type
        ) ?? (invoiceEntity.pdfFilePath ?? .currentDirectory())
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
    
    func showDeleteAlert() {
        isShowDeleteAlert = true
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
            let type: InvoiceType = isInvoice ? .invoice : .estimate
            let resolvedURL = fileManagerPDFService.resolvePDFURL(storedURL: pdfFilePath, for: type) ?? pdfFilePath
            let data = try Data(contentsOf: resolvedURL)
            ContactSheet.shared.presentContactSheetWithPdf(
                pdfData: data,
                fileName: "Invoice.pdf",
                mail: invoiceEntity.client?.email ?? "",
                completion: { result in
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
