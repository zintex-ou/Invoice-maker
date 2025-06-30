import SwiftUI
import Combine

@MainActor
final class ClientInvoicesListViewModel: ObservableObject {
    @Published var invoiceSelection: SegmentInvoiceType = .all
    @Published var allInvoices: [InvoiceEntity] = []
    @Published var paidInvoices: [InvoiceEntity] = []
    @Published var unpaidInvoices: [InvoiceEntity] = []
    
    private let report: ClientInvoiceReport
    private let dataBaseService = InvoiceDataBaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var title: String {
        report.name
    }
    
    init(report: ClientInvoiceReport) {
        self.report = report
       
        bindToDataBaseService()
        fetchInvoicesForClient()
    }
    
    func change(isPaid: Bool, for id: UUID) {
        Task {
            do {
                try await dataBaseService.change(isPaid: isPaid, for: id)
            } catch {
                print("Failed to update invoice")
            }
        }
    }
    
    func getInvoices() -> [InvoiceEntity] {
        switch invoiceSelection {
        case .all:
            return allInvoices
        case .paid:
            return paidInvoices
        case .unpaid:
            return unpaidInvoices
        }
    }
    
    private func bindToDataBaseService() {
        dataBaseService.$allInvoices
            .map { [weak self] invoices in
                invoices.filter { $0.client == self?.report.client }
            }
            .assign(to: \.allInvoices, on: self)
            .store(in: &cancellables)
        
        dataBaseService.$paidInvoices
            .map { [weak self] invoices in
                invoices.filter { $0.client == self?.report.client }
            }
            .assign(to: \.paidInvoices, on: self)
            .store(in: &cancellables)
        
        dataBaseService.$unPaidInvoices
            .map { [weak self] invoices in
                invoices.filter { $0.client == self?.report.client }
            }
            .assign(to: \.unpaidInvoices, on: self)
            .store(in: &cancellables)
    }
    
    private func fetchInvoicesForClient() {
        Task {
            await dataBaseService.fetchInvoices()
        }
    }
}
