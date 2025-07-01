import Foundation
import Reachability
import SwiftUI
import Combine
import Adapty

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var shouldShowCloseButton: Bool = false
    @Published var isLoading: Bool = false
    @Published var shouldShowAlert: Bool = false
    @Published var shouldShowTryAgainAlert: Bool = false
    @Published var product: AdaptyPaywallProduct?
    
    private var reachibility: Reachability?
    private let keychainManager: KeychainManager = .init()
    private let purchasesManager: PurchaseManager = .shared
    private let remoteConfigManager: RemoteConfigManager = .shared
    private var cancellable: AnyCancellable?
    private var isActiveSubscription: Bool = false
    
    var metaData: [OnboardingModel] = []
    
    var alert: AlertModel = .init(title: "", subtitle: "")
    
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
                return "With 3 days trial, then \(product.currencySymbol ?? "$")\(price)/\(duration)"
            } else {
                return "Subscribe for \(product.currencySymbol ?? "$")\(price)/\(duration)"
            }
        } else {
            return "Continue"
        }
    }
    
    func fetchPayWall() async {
        self.isLoading = true
        
        defer {
            self.isLoading = false
        }
        
        do {
            let paywall = try await purchasesManager.fetchPaywall()
            await fetchPayWallProducts(paywall: paywall)
        }  catch {
            if let error = AdaptyErrorManager.init(error: error).error {
                alert = .init(title: error.title, subtitle: error.subTitle)
                self.shouldShowAlert = true
            }
        }
    }
    
    func tapOnRestore(completion: @escaping () -> Void) {
        Task {
            await tapOnRestore(completion: completion)
        }
    }
    
    func makePurchase(completion: @escaping () -> Void) async {
        self.isLoading = true
        
        defer {
            self.isLoading = false
        }
        
        guard reachibility?.connection != .unavailable else {
            alert = .init(title: "Bad Connection", subtitle: "Please, turn on the internet to get full access to the features")
            self.shouldShowAlert = true
            return
        }
        
        guard let product else {
            alert = .init(title: "Ooops...", subtitle: "Something went wrong.\nPlease try again.")
            self.shouldShowAlert = true
            return
        }
        
        do {
            let result = try await purchasesManager.makePurchase(product: product)
            
            switch result {
            case .userCancelled:
                alert = .init(title: "Ooops...", subtitle: "Something went wrong.\nPlease try again.")
                if remoteConfigManager.config.paywallConfig.showAlertAfterCanceledPurchase {
                    shouldShowTryAgainAlert = true
                } else {
                    self.shouldShowAlert = true
                }
            case .pending:
                break
            case .success:
                completion()
            }
        } catch {
            if let error = AdaptyErrorManager.init(error: error).error {
                alert = .init(title: error.title, subtitle: error.subTitle)
                self.shouldShowAlert = true
            }
        }
    }
    
    private func tapOnRestore(completion: @escaping () -> Void) async {
        self.isLoading = true
        
        defer {
            self.isLoading = false
        }
        
        guard reachibility?.connection != .unavailable else {
            alert = .init(title: "Bad Connection", subtitle: "Please, turn on the internet to get full access to the features")
            self.shouldShowAlert = true
            return
        }
        
        do {
            try await purchasesManager.restorePurchases()
            if isActiveSubscription {
                completion()
            } else {
                alert = .init(title: "No active subscription", subtitle: "You have no active subscriptions, please check your subscription status.")
                self.shouldShowAlert = true
            }
        } catch {
            if let error = AdaptyErrorManager.init(error: error).error {
                alert = .init(title: error.title, subtitle: error.subTitle)
                self.shouldShowAlert = true
            }
        }
    }
    
    private func fetchPayWallProducts(paywall: AdaptyPaywall) async {
        self.isLoading = true
        
        defer {
            self.isLoading = false
        }
        
        do {
            let products = try await purchasesManager.fetchPaywallProducts(paywall: paywall)
            await MainActor.run {
                product = products.first
                updateSubtileInOnboarding()
            }
        } catch {
            if let error = AdaptyErrorManager.init(error: error).error {
                alert = .init(title: error.title, subtitle: error.subTitle)
                self.shouldShowAlert = true
            }
        }
    }
    
    private func setupSubscribers() {
        cancellable = purchasesManager.isPremium
            .receive(on: RunLoop.main)
            .assign(to: \.isActiveSubscription, on: self)
    }
    
    private func updateSubtileInOnboarding() {
        guard let product else { return }
        
        let price = String(describing: NSDecimalNumber(decimal: product.price).floatValue)
        let currency = product.currencySymbol ?? "$"
        let newSubtitle: LocalizedStringKey = "Generate professional invoices with just a few taps per week for \(currency)\(price) with 3 days free trial."
        
        metaData[3] = OnboardingModel(
            image: .onboard4,
            title: metaData[3].title,
            subtitle: newSubtitle
        )
    }
}
