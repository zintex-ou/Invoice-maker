import SwiftUI

final class ClientInvoicesListViewModel: ObservableObject {
    let report: ClientInvoiceReport
    @Published var popovers: [UUID: Bool] = [:]
    @Published var invoiceSelection: SegmentInvoiceType = .all
    
    private var allDetailViewModels: [InvoiceDetailViewModel] {
        report.detailViewModels(
            popovers: Binding(
                get: { [weak self] in self?.popovers ?? [:] },
                set: { [weak self] newValue in self?.popovers = newValue }
            )
        )
    }
    
    var filteredDetailViewModels: [InvoiceDetailViewModel] {
        switch invoiceSelection {
        case .all:
            return allDetailViewModels
        case .paid:
            return allDetailViewModels.filter { $0.isPaid.wrappedValue }
        case .unpaid:
            return allDetailViewModels.filter { !$0.isPaid.wrappedValue }
        }
    }
    
    init(report: ClientInvoiceReport) {
        self.report = report
        report.detailViewModels(
            popovers: .constant([:])
        ).forEach { model in
            popovers[model.id] = false
        }
    }
    
    #warning("add update")
    func updateStatus() {
        
    }
}
