import SwiftUICore

enum SegmentOfferType: CaseIterable, SegmentedItemProtocol {
    case items
    case services

    var title: LocalizedStringKey {
        switch self {
        case .items: "Items"
        case .services: "Services"
        }
    }
}
