import SwiftUICore

enum SegmentInvoiceType: CaseIterable, SegmentedItemProtocol {
    case all
    case paid
    case unpaid

    var title: LocalizedStringKey {
        switch self {
        case .all: "All"
        case .paid: "Paid"
        case .unpaid: "Unpaid"
        }
    }
}
