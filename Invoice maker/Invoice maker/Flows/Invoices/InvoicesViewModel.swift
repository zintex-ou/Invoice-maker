import SwiftUI

@MainActor
final class InvoicesViewModel: ObservableObject {
    @Published var invoiceSelection: SegmentInvoiceType = .all
    @Published var isPremium: Bool = false
    @Published var allInvoices: [InvoiceEntity] = []
    @Published var paidInvoices: [InvoiceEntity] = []
    @Published var unPaidInvoices: [InvoiceEntity] = []
    
    private let userDefaultsPDFService = UserDefaultsPDFService()
    private let dataBaseManager = CoreDataManager.shared

    init() {}
    
    func fetchInvoices() async {
        do {
            let result = try await dataBaseManager.fetchInvoices(ofType: .invoice)
            allInvoices = result
            paidInvoices = result.filter({ $0.isPaid == true })
            unPaidInvoices = result.filter({ $0.isPaid == false })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func changeIsPaid(status: Bool, for id: UUID) {
        guard let index = allInvoices.firstIndex(where: { $0.id == id }) else { return }
        allInvoices[index].isPaid = status
    }
}
