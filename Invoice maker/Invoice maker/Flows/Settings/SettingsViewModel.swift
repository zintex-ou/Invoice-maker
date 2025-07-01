import SwiftUI
import Reachability
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var shouldShowAlert: Bool = false
    @Published var isLoading: Bool = false
    
    private let purchaseManager: PurchaseManager = .shared
    private var reachibility: Reachability?
    private var cancellable: AnyCancellable?
    private let feedbackGenerator = FeedbackGenerator.shared
    
    var alert: AlertModel = .init(title: "", subtitle: "")
    
    init() {
        setupSubscribers()
    }
}

extension SettingsViewModel {
    func tapOnSettingsButton(type: SettingType) {
        switch type {
        case .share: shareApp()
        case .contact: contactUs()
        case .privacy: openPrivacy()
        case .terms: openTerms()
        case .restore:
            Task {
                await restore()
            }
        default: feedbackGenerator.getFeedback()
        }
    }
}

private extension SettingsViewModel {
    private func shareApp() {
        feedbackGenerator.getFeedback()
        UIApplication.shared.shareApp()
    }
    
    private func contactUs() {
        feedbackGenerator.getFeedback()
        ContactSheet.shared.presentContactSheet()
    }
    
    private func openPrivacy() {
        feedbackGenerator.getFeedback()
        UIApplication.shared.openPrivacy()
    }
    
    private func openTerms() {
        feedbackGenerator.getFeedback()
        UIApplication.shared.openTerms()
    }
    
    private func restore() async {
        self.isLoading = true
        
        defer {
            self.isLoading = false
        }
        
        guard reachibility?.connection != .unavailable else {
            alert = .init(title: "Bad Connection", subtitle: "Please, turn on the internet to get full access to the features")
            shouldShowAlert = true
            return
        }
        
        do {
            try await purchaseManager.restorePurchases()
            
            if isPremium {
                alert = .init(title: "Subscription Restored", subtitle: "Your subscription has been successfully restored. Enjoy full access to all features.")
                shouldShowAlert = true
            } else {
                alert = .init(title: "No active subscription", subtitle: "You have no active subscriptions, please check your subscription status.")
                shouldShowAlert = true
            }
        } catch {
            if let error = AdaptyErrorManager.init(error: error).error {
                alert = .init(title: error.title, subtitle: error.subTitle)
                shouldShowAlert = true
            }
        }
    }
    
    private func setupSubscribers() {
        cancellable = purchaseManager.isPremium
            .receive(on: RunLoop.main)
            .assign(to: \.isPremium, on: self)
    }
}
