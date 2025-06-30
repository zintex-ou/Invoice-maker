import SwiftUI
import Combine

@MainActor
final class InvoicesViewModel: ObservableObject {
    @Published var invoiceSelection: SegmentInvoiceType = .all
    @Published var isPremium: Bool = false
    @Published var allInvoices: [InvoiceEntity] = []
    @Published var paidInvoices: [InvoiceEntity] = []
    @Published var unPaidInvoices: [InvoiceEntity] = []
    
    private let dataBaseService = InvoiceDataBaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindToDataBaseService()
        setupSubscriptions()
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
            return unPaidInvoices
        }
    }
}

extension InvoicesViewModel {
    private func bindToDataBaseService() {
        dataBaseService.$allInvoices
            .assign(to: \.allInvoices, on: self)
            .store(in: &cancellables)
        
        dataBaseService.$paidInvoices
            .assign(to: \.paidInvoices, on: self)
            .store(in: &cancellables)
        
        dataBaseService.$unPaidInvoices
            .assign(to: \.unPaidInvoices, on: self)
            .store(in: &cancellables)
    }
    
    private func setupSubscriptions() {
        NotificationService.shared.observe(event: .updateIsPaid) { [weak self] _ in
            guard let self else { return }

        }
    }
}
