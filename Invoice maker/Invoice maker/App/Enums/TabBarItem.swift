import SwiftUI

enum TabBarItem: Int, CaseIterable {
    case invoices
    case estimates
    case reports
    case settings
    
    var title: LocalizedStringKey {
        switch self {
        case .invoices: "Invoices"
        case .estimates: "Estimates"
        case .reports: "Reports"
        case .settings: "Settings"
        }
    }
    
    var icon: ImageResource {
        switch self {
        case .invoices: .property1Invoices
        case .estimates: .property1Estimates
        case .reports: .property1Reports
        case .settings: .property1Settings
        }
    }
    
    var activeIcon: ImageResource {
        switch self {
        case .invoices: .property1InvoicesActive
        case .estimates: .property1EstimatesActive
        case .reports: .property1ReportsActive
        case .settings: .property1SettingsActive
        }
    }
}
