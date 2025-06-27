import Foundation

@MainActor
final class DataBaseService {
    static let shared = DataBaseService()
    private let dataBaseManager = CoreDataManager.shared
    
    @Published var allInvoices: [InvoiceEntity] = []
    @Published var paidInvoices: [InvoiceEntity] = []
    @Published var unPaidInvoices: [InvoiceEntity] = []
    
    @Published var allEstimates: [InvoiceEntity] = []
    
    private init() {}
    
    func fetchInvoices() async {
        do {
            let result = try await dataBaseManager.fetchInvoices()
            
            var invoices: [InvoiceEntity] = []
            var estimates: [InvoiceEntity] = []
            var paid: [InvoiceEntity] = []
            var unpaid: [InvoiceEntity] = []
            
            for item in result {
                if item.isInvoice {
                    invoices.append(item)
                    if item.isPaid {
                        paid.append(item)
                    } else {
                        unpaid.append(item)
                    }
                } else {
                    estimates.append(item)
                }
            }
            
            allInvoices = invoices
            paidInvoices = paid
            unPaidInvoices = unpaid
            allEstimates = estimates
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createInvoice(with model: InvoiceInput) async throws -> InvoiceEntity {
        let invoice = try await CoreDataManager.shared.createInvoice(input: model)
        if invoice.isInvoice {
            allInvoices.insert(invoice, at: 0)
            if invoice.isPaid {
                paidInvoices.insert(invoice, at: 0)
            } else {
                unPaidInvoices.insert(invoice, at: 0)
            }
        } else {
            allEstimates.insert(invoice, at: 0)
        }
        
        return invoice
    }
    
    func change(isPaid: Bool, for id: UUID) async {
        guard let index = allInvoices.firstIndex(where: { $0.id == id }) else { return }
        allInvoices[index].isPaid = isPaid
        
        if isPaid {
            guard let unPaidIndex = unPaidInvoices.firstIndex(where: { $0.id == id }) else { return }
            let inPaidInvoice = unPaidInvoices.remove(at: unPaidIndex)
            paidInvoices.append(inPaidInvoice)
        } else {
            guard let paidIndex = paidInvoices.firstIndex(where: { $0.id == id }) else { return }
            let invoice = paidInvoices.remove(at: paidIndex)
            unPaidInvoices.append(invoice)
        }
    }
}
