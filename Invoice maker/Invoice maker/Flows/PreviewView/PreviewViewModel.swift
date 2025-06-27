import SwiftUI

final class PreviewViewModel: ObservableObject {
    var pdfFilePath: URL
    var alert: AlertModel = .init(title: "", subtitle: "")
    var isWithStatusChange: Bool
    private var invoiceEntity: InvoiceEntity
    let isInvoice: Bool
    
    @Published var shouldShowError: Bool = false
    @Published var isPaid: Bool = false
    @Published var isPaidPopShow = false
    @Published var popoverID: Int = 1
    
    init(
        invoiceEntity: InvoiceEntity,
        isWithStatusChange: Bool = false
    ) {
            self.invoiceEntity = invoiceEntity
            self.pdfFilePath = invoiceEntity.pdfFilePath ?? .currentDirectory()
            self.isWithStatusChange = isWithStatusChange
            self.isInvoice = invoiceEntity.isInvoice
        }
    
    func title() -> String {
        isInvoice ? "Preview" : "Estimate"
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
        isPaidPopShow  = false
        Task {
            await updateInvoice()
        }
    }
    
    func updateInvoice() async {
        do {
            if let client = invoiceEntity.client,
               let itemService = invoiceEntity.itemService {
                let input = InvoiceInput(
                    id: invoiceEntity.id ?? .init(),
                    client: client,
                    number: invoiceEntity.invoiceNumber ?? "",
                    invoiceDate: invoiceEntity.invoiceDate ?? .now,
                    dueDate: invoiceEntity.dueDate ?? .now,
                    currency: invoiceEntity.currency ?? "USD",
                    discount: invoiceEntity.discount ?? "",
                    tax: invoiceEntity.tax ?? "",
                    isPaid: isPaid,
                    total: invoiceEntity.total,
                    itemOrServices: (itemService as? Set<ItemServiceEntity>)?.map { $0 } ?? [],
                    pdfFilePath: invoiceEntity.pdfFilePath ?? .currentDirectory(),
                    type: .init(rawValue: invoiceEntity.type ?? "topDark") ?? TemplateType.topDark,
                    isInvoice: invoiceEntity.isInvoice
                )
                try await CoreDataManager.shared.updateInvoice(
                    input: input
                )
            }
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
