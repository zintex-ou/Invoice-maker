import SwiftUI

final class ClientInvoicesListViewModel: ObservableObject {
    private let report: ClientInvoiceReport
    @Published var invoiceSelection: SegmentInvoiceType = .all
    
    private var allDetailViewModels: [InvoiceDetailViewModel] {
        report.detailViewModels()
    }
    
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
    
    #warning("add update")
    func updateStatus(isPaid: Bool) {
        
    }
}
