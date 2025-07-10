import Foundation
import Reachability
import SwiftUI
import Adapty
import Combine

final class PaywallViewModel: ObservableObject {
    @Published var shouldShowNotNowButton: Bool = false
    @Published var isLoading: Bool = false
    @Published var shouldShowAlert: Bool = false
    @Published var shouldShowTryAgainAlert: Bool = false
    @Published var continueButtonText: LocalizedStringKey = "Continue"
    
    @Published var products: [SubscriptionModel] = [
        SubscriptionModel(productId: UUID().uuidString,
                          nameProduct: NSLocalizedString("Weekly", comment: ""),
                          period: "\(NSLocalizedString("week", comment: ""))",
                          price: 6.99,
                          currency: "$",
                          badgeText: "3 days free trial",
                          isFreeTrial: true,
                          trialDays: 0),
        SubscriptionModel(productId: UUID().uuidString,
                          nameProduct: NSLocalizedString("Monthly", comment: ""),
                          period: "\(NSLocalizedString("month", comment: ""))",
                          price: 19.99,
                          currency: "$",
                          badgeText: nil,
                          isFreeTrial: false,
                          trialDays: 0),
        SubscriptionModel(productId: UUID().uuidString,
                          nameProduct: NSLocalizedString("Yearly", comment: ""),
                          period: "\(NSLocalizedString("year", comment: ""))",
                          price: 59.99,
                          currency: "$",
                          badgeText: nil,
                          isFreeTrial: false,
                          trialDays: 0)
    ]
    
    @Published var selectedProduct: SubscriptionModel?
    
    private let purchasesManager: PurchaseManager = .shared
    private let keychainManager: KeychainManager = .init()
    private let remoteConfigManager: RemoteConfigManager = .shared
    private var reachibility: Reachability?
    private var adaptyProducts: [AdaptyPaywallProduct] = []
    private var isActiveSubscription: Bool = false
    private var cancellable: AnyCancellable?

    var title: LocalizedStringKey = ""
    var subTitle: LocalizedStringKey = ""

    init() {
        self.reachibility = try? Reachability()
        
        selectedProduct = products.first
        
        setupSubscribers()
        
        if let selectedProduct {
            continueButtonText(product: selectedProduct)
        }
    }
    
    func tapOnContinue(completion: @escaping () -> Void) {
        Task {
            await makePurchase(completion: completion)
        }
    }
    
    func tapOnPrivacy() {
        UIApplication.shared.openPrivacy()
    }
    
    func tapOnTerms() {
        UIApplication.shared.openTerms()
    }

    func isNeedShowButton() {
        let second = remoteConfigManager.config.paywallConfig.closeActionDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(second)) {
            self.shouldShowNotNowButton = true
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
    
    private func fetchPayWallProducts(paywall: AdaptyPaywall) async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let products = try await purchasesManager.fetchPaywallProducts(paywall: paywall)
            await MainActor.run {
                self.adaptyProducts = products
                
                self.products = products
                    .enumerated()
                    .map({
                            index,
                            product in
                            
                            var badgeText: String?
                            var isFreeTrial: Bool = false
                            var period: String = ""
                            var trialDays = 0
                            var nameProduct: String = ""
                            
                            if !product.localizedTitle.isEmpty {
                                if product.localizedTitle == "Weekly" {
                                    period = NSLocalizedString("week", comment: "")
                                    nameProduct = NSLocalizedString("Weekly", comment: "")
                                } else if product.localizedTitle == "Monthly" {
                                    period = NSLocalizedString("month", comment: "")
                                    nameProduct = NSLocalizedString("Monthly", comment: "")
                                } else if product.localizedTitle == "Yearly" {
                                    period = NSLocalizedString("year", comment: "")
                                    nameProduct = NSLocalizedString("Yearly", comment: "")
                                }
                            }
                            
                            if let subscriptionOffer = product.subscriptionOffer,
                               subscriptionOffer.offerType == .introductory {
                                isFreeTrial = true
                                trialDays = subscriptionOffer.subscriptionPeriod.numberOfUnits
                                badgeText = "\(NSLocalizedString("days free trial", comment: ""))"
                            }
                            
                            return .init(
                                productId: product.vendorProductId,
                                nameProduct: nameProduct,
                                period: period,
                                price: NSDecimalNumber(decimal: product.price).floatValue,
                                currency: product.currencySymbol ?? "$",
                                badgeText: badgeText,
                                isFreeTrial: isFreeTrial,
                                trialDays: trialDays
                            )
                        })
                
                selectedProduct = self.products.first
                
                if let selectedProduct {
                    continueButtonText(product: selectedProduct)
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
    
    private func makePurchase(completion: @escaping () -> Void) async {
        guard reachibility?.connection != .unavailable else {
            showAlert(
                title: "Bad Connection",
                subTitle: "Please, turn on the internet to get full access to the features"
            )
            return
        }
        
        guard let selectedProduct,
              let selectedAdaptyProduct = adaptyProducts
            .first(where: { $0.vendorProductId == selectedProduct.productId }) else {
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
            let result = try await purchasesManager.makePurchase(product: selectedAdaptyProduct)
            
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
    
    private func showAlert(title: LocalizedStringKey, subTitle: LocalizedStringKey) {
        DispatchQueue.main.async {
            self.title = title
            self.subTitle = subTitle
            self.shouldShowAlert = true
        }
    }
    
    func tapOnRestore(completion: @escaping () -> Void) async {
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
    
    func continueButtonText(product: SubscriptionModel) {
        if self.remoteConfigManager.config.paywallConfig.showPriceTitle {
            
            let price = String(describing: product.price)
            let duration = product.period
            
            if !product.isFreeTrial {
                continueButtonText = "Subscribe for \(product.currency)\(price)/\(duration)"
            } else {
                continueButtonText = "With 3 days trial, then \(product.currency)\(price)/\(duration)"
            }
            
        } else {
            continueButtonText = "Continue"
        }
    }

    private func setupSubscribers() {
        cancellable = purchasesManager.isPremium
            .receive(on: RunLoop.main)
            .assign(to: \.isActiveSubscription, on: self)
    }
}
