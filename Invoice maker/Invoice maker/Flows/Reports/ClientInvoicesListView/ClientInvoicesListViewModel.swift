import SwiftUI

final class ClientInvoicesListViewModel: ObservableObject {
    private let report: ClientInvoiceReport
    @Published var invoiceSelection: SegmentInvoiceType = .all
    
    private var allDetailViewModels: [InvoiceDetailViewModel] {
        report.detailViewModels()
    }
    
    private let dataBaseService = InvoiceDataBaseService.shared
    
    var title: String {
        report.name
    }
    
    var filteredDetailViewModels: [InvoiceDetailViewModel] {
        switch invoiceSelection {
        case .all:
            return allDetailViewModels
        case .paid:
            return allDetailViewModels.filter { $0.isPaid }
        case .unpaid:
            return allDetailViewModels.filter { !$0.isPaid }
        }
    }
    
    init(report: ClientInvoiceReport) {
        self.report = report
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
}
