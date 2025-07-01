import SwiftUI
import Reachability
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var shouldShowAlert: Bool = false
    @Published var isLoading: Bool = false
    
    private let purchaseManager: PurchaseManager = .shared
    private var reachibility: Reachability?
    private var cancellable: AnyCancellable?
    
    var title: LocalizedStringKey = ""
    var subTitle: LocalizedStringKey = ""

    private let feedbackGenerator = FeedbackGenerator.shared

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
    
    private func showAlert(title: LocalizedStringKey, subTitle: LocalizedStringKey) {
        DispatchQueue.main.async {
            self.title = title
            self.subTitle = subTitle
            self.shouldShowAlert = true
        }
    }

    private func restore() async {
        guard reachibility?.connection != .unavailable else {
            showAlert(
                title: "Bad Connection",
                subTitle: "Please, turn on the internet to get full access to the features"
            )
            return
        }
        
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            try await purchaseManager.restorePurchases()
            await MainActor.run {
                if isPremium {
                    showAlert(
                        title: "Subscription Restored",
                        subTitle: "Your subscription has been successfully restored. Enjoy full access to all features."
                    )
                } else {
                    showAlert(
                        title: "No active subscription",
                        subTitle: "You have no active subscriptions, please check your subscription status."
                    )
                }
            }
        } catch {
            if let error = AdaptyErrorManager.init(error: error).error {
                showAlert(title: error.title, subTitle: error.subTitle)
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    private func setupSubscribers() {
        cancellable = purchaseManager.isPremium
            .receive(on: RunLoop.main)
            .assign(to: \.isPremium, on: self)
    }
}
