import Foundation

@MainActor
final class InvoiceDataBaseService {
    static let shared = InvoiceDataBaseService()
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
    
    func update(invoice: InvoiceInput) async throws -> InvoiceEntity {
        self.allInvoices = self.allInvoices.filter { $0.id != invoice.id }
        self.paidInvoices = self.paidInvoices.filter { $0.id != invoice.id }
        self.unPaidInvoices = self.unPaidInvoices.filter { $0.id != invoice.id }
        
        let invoice = try await CoreDataManager.shared.updateInvoice(input: invoice)
        return invoice
    }
    
    func change(isPaid: Bool, for id: UUID) async throws {
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
        
        try? await dataBaseManager.updateIsPaid(for: id, isPaid: isPaid)
    }
    
    func deleteInvoice(with id: UUID) async throws {
        self.allInvoices = self.allInvoices.filter { $0.id != id }
        self.paidInvoices = self.paidInvoices.filter { $0.id != id }
        self.unPaidInvoices = self.unPaidInvoices.filter { $0.id != id }
        
        try await dataBaseManager.deleteInvoice(byID: id)
    }
    
    func deleteEstimate(with id: UUID) async throws {
        self.allEstimates = self.allEstimates.filter { $0.id != id }
        try await dataBaseManager.deleteInvoice(byID: id)
    }
}
