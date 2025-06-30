import Foundation
import Reachability
import SwiftUI
import Combine
import Adapty

final class OnboardingViewModel: ObservableObject {
    @Published var shouldShowCloseButton: Bool = false
    @Published var isLoading: Bool = false
    @Published var shouldShowAlert: Bool = false
    @Published var shouldShowTryAgainAlert: Bool = false
    @Published var product: AdaptyPaywallProduct?
    
    @Device private var device
    
    private var reachibility: Reachability?
    private let keychainManager: KeychainManager = .init()
    private let purchasesManager: PurchaseManager = .shared
    private let remoteConfigManager: RemoteConfigManager = .shared
    private var cancellable: AnyCancellable?
    private var isActiveSubscription: Bool = false
    
    var metaData: [OnboardingModel] = []
    
    var title: LocalizedStringKey = ""
    var subTitle: LocalizedStringKey = ""
    
    init() {
        metaData = [
            .init(
                image: .onboard1,
                title: "Create Invoices\nin Seconds",
                subtitle: "Generate professional invoices with just\na few taps — fast, simple, and error-free."
            ),
            .init(
                image: .onboard2,
                title: "Manage Clients\nEffortlessly",
                subtitle: "Keep all your client info in one place\nand track billing with ease."
            ),
            .init(
                image: .onboard3,
                title: "Stay Organized\n& In Control",
                subtitle: "Track income, monitor status, and\nmanage your business like a pro."
            ),
            .init(
                image: .onboard4,
                title: "Create Invoices\nin Seconds",
                subtitle: "Generate professional invoices with just a few taps — fast, simple, and error-free."
            )
        ]
        
        self.reachibility = try? Reachability()
        
        setupSubscribers()
    }
    
    func showCloseButton() {
        let second = RemoteConfigManager.shared.config.paywallConfig.closeActionDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(second)) {
            self.shouldShowCloseButton = true
        }
    }
    
    func continueButtonText() -> LocalizedStringKey {
        guard let product else { return "Continue" }
        
        if self.remoteConfigManager.config.paywallConfig.showPriceTitle {
            
            let price = String(describing: NSDecimalNumber(decimal: product.price).floatValue)
            let duration = NSLocalizedString("week", comment: "")
            
            if let subscriptionOffer = product.subscriptionOffer,
               subscriptionOffer.offerType == .introductory {
                return "With 3 day trial, then \(product.currencySymbol ?? "$")\(price)/\(duration)"
            } else {
                return "Subscribe for \(product.currencySymbol ?? "$")\(price)/\(duration)"
                
            }
            
        } else {
            return "Continue"
        }
    }
    
    func fetchPayWall() async {
        await MainActor.run {
            self.isLoading = true
        }
        do {
            let paywall = try await purchasesManager.fetchPaywall()
            await fetchPayWallProducts(paywall: paywall)
        }  catch {
            await MainActor.run {
                self.isLoading = false
            }
            if let error = AdaptyErrorManager.init(error: error).error {
                showAlert(title: error.title, subTitle: error.subTitle)
            }
        }
    }
    
    func tapOnRestore(completion: @escaping () -> Void) {
        Task {
            await tapOnRestore(completion: completion)
        }
    }
    
    func makePurchase(completion: @escaping () -> Void) async {
        guard reachibility?.connection != .unavailable else {
            showAlert(
                title: "Bad Connection",
                subTitle: "Please, turn on the internet to get full access to the features"
            )
            return
        }
        
        guard let product else {
            showAlert(
                title: "Ooops...",
                subTitle: "Something went wrong.\nPlease try again."
            )
            return
        }
        
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let result = try await purchasesManager.makePurchase(product: product)
            
            switch result {
            case .userCancelled:
                if remoteConfigManager.config.paywallConfig.showAlertAfterCanceledPurchase {
                    title = "Ooops..."
                    subTitle = "Something went wrong.\nPlease try again."
                    
                    await MainActor.run {
                        shouldShowTryAgainAlert = true
                    }
                } else {
                    showAlert(title: "Ooops...", subTitle: "Something went wrong.\nPlease try again.")
                }
            case .pending:
                break
            case .success:
                await MainActor.run {
                    completion()
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
    
    private func tapOnRestore(completion: @escaping () -> Void) async {
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
            try await purchasesManager.restorePurchases()
            await MainActor.run {
                if isActiveSubscription {
                    completion()
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
    
    private func fetchPayWallProducts(paywall: AdaptyPaywall) async {
        await MainActor.run {
            self.isLoading = true
        }
        do {
            let products = try await purchasesManager.fetchPaywallProducts(paywall: paywall)
            await MainActor.run {
                product = products.first
                updateSubtileInOnboarding()
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
        cancellable = purchasesManager.isPremium
            .receive(on: RunLoop.main)
            .assign(to: \.isActiveSubscription, on: self)
    }
    
    private func showAlert(title: LocalizedStringKey, subTitle: LocalizedStringKey) {
        DispatchQueue.main.async {
            self.title = title
            self.subTitle = subTitle
            self.shouldShowAlert = true
        }
    }
    
    private func updateSubtileInOnboarding() {
        guard let product else { return }
        
        let price = String(describing: NSDecimalNumber(decimal: product.price).floatValue)
        let currency = product.currencySymbol ?? "$"
        let newSubtitle: LocalizedStringKey = "Generate professional invoices with just a few taps per week for \(currency)\(price) with free trial."
 
        metaData[3] = OnboardingModel(
            image: .onboard4,
            title: metaData[3].title,
            subtitle: newSubtitle
        )
    }
}
