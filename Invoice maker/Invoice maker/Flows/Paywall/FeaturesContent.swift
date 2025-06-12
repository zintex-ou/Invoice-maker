import SwiftUI

enum FeaturesContent: CaseIterable {
    case unlimitedInvoices
    case unlimitedEstimates
    case exportInvoices
    
    var title: LocalizedStringKey {
        switch self {
        case .unlimitedInvoices:
            return "Send unlimited invoices"
        case .unlimitedEstimates:
            return "Create unlimited estimates"
        case .exportInvoices:
            return "Delete, edit & export invoices"
        }
    }
    
    var icon: ImageResource {
        .paywallFeature
    }
}
