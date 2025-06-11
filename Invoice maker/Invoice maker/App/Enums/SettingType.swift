import SwiftUI

enum SettingType: String, CaseIterable {
    case profile
    case clients
    case services
    case rate
    case share
    case contact
    case privacy
    case terms
    case restore

    var title: LocalizedStringKey {
        switch self {
        case .profile: "Business profile"
        case .clients: "Clients"
        case .services: "Items & services"
        case .rate: "Rate app"
        case .share: "Share app"
        case .contact: "Contact us"
        case .privacy: "Terms of use"
        case .terms: "Privacy policy"
        case .restore: "Restore purchase"
        }
    }

    var icon: ImageResource {
        switch self {
        case .profile: .property1Profile
        case .clients: .property1Client
        case .services: .property1Item
        case .rate: .property1RateApp
        case .share: .property1Share
        case .contact: .property1ContactUs
        case .privacy: .property1Policy
        case .terms: .property1TermsOfUse
        case .restore: .property1Restrore
        }
    }
}

enum SettingSection: CaseIterable {
    case business
    case general

    var title: LocalizedStringKey {
        switch self {
        case .business: ""
        case .general: "General"
        }
    }

    var items: [SettingType] {
        switch self {
        case .business: [.profile, .clients, .services]
        case .general: [.rate, .share, .contact, .privacy, .terms, .restore]
        }
    }
}
