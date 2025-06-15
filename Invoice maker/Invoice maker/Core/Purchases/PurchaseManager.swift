import Adapty
@preconcurrency import Combine
import UIKit

final class PurchaseManager {
    static let shared = PurchaseManager()
    
    private let isPremiumSubject = CurrentValueSubject<Bool, Never>(false)
    
    lazy var isPremium: AnyPublisher<Bool, Never> = isPremiumSubject
        .removeDuplicates()
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    
    private let keychainManager: KeychainManager = .init()
    
    private init() {
        let configurationBuilder =
            AdaptyConfiguration
                .builder(withAPIKey: AppConstants.getValue(.adaptyKey))
                .with(observerMode: false)
                .with(customerUserId: userIdKey)
                .with(idfaCollectionDisabled: false)
                .with(ipAddressCollectionDisabled: false)
                .with(logLevel: .verbose)
        
        Adapty.activate(with: configurationBuilder.build()) { error in
            print(error?.localizedDescription as Any)
        }

        Adapty.delegate = self
        
        isPremiumSubject.send(isActivityPurchases())
        
        Task {
            await fetchProfile()
        }
    }
    
    func fetchPaywall() async throws -> AdaptyPaywall {
        try await Adapty.getPaywall(placementId: "paywall_placement")
    }
    
    func fetchPaywallProducts(paywall: AdaptyPaywall) async throws -> [AdaptyPaywallProduct] {
        try await Adapty.logShowPaywall(paywall)
        return try await Adapty.getPaywallProducts(paywall: paywall)
    }
    
    func makePurchase(product: AdaptyPaywallProduct) async throws -> AdaptyPurchaseResult {
        let purchasesResult = try await Adapty.makePurchase(product: product)
        saveExpiresPurchasesToStorage(profile: purchasesResult.profile)

        await MainActor.run {
            let isPremium = purchasesResult.profile?.accessLevels.contains(where: { $0.value.isActive }) ?? false
            self.isPremiumSubject.send(isPremium)
        }
        
        return purchasesResult
    }
    
    func restorePurchases() async throws {
        let profile = try await Adapty.restorePurchases()
        saveExpiresPurchasesToStorage(profile: profile)
        await MainActor.run {
            let isPremium = profile.accessLevels.contains(where: { $0.value.isActive })
            self.isPremiumSubject.send(isPremium)
        }
    }
    
    func isActivityPurchases() -> Bool {
        guard let expiresAt = keychainManager.purchasesExpiresAt else { return false }
        return Date() < expiresAt
    }
}

extension PurchaseManager: AdaptyDelegate {
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        saveExpiresPurchasesToStorage(profile: profile)
        let isPremium = profile.accessLevels.contains(where: { $0.value.isActive })
        isPremiumSubject.send(isPremium)
        
        if !isPremium {
            UIApplication.shared.shortcutItems = []
        } else {
            configureShortCut()
        }
    }
}

extension PurchaseManager {
    private var userIdKey: String {
        if let userIdKey = keychainManager.userIdKey {
            return userIdKey
        } else {
            let userIdKey = UUID().uuidString
            keychainManager.userIdKey = userIdKey
            return userIdKey
        }
    }
    
    private func fetchProfile() async {
        do {
            let profile = try await Adapty.getProfile()
            saveExpiresPurchasesToStorage(profile: profile)
            await MainActor.run {
                let isPremium = profile.accessLevels.contains(where: { $0.value.isActive })
                self.isPremiumSubject.send(isPremium)
            }
        } catch {
            guard let adaptyError = error as? AdaptyError else { return }
            print(adaptyError.description)
        }
    }
    
    private func saveExpiresPurchasesToStorage(profile: AdaptyProfile?) {
        guard let profile else { return }
        keychainManager.purchasesExpiresAt = profile.accessLevels["premium"]?.expiresAt
    }
    
    private func configureShortCut() {
        let shortcutItem = UIApplicationShortcutItem(
            type: ShortCutType.mail.rawValue,
            localizedTitle: "Stop Subscription",
            localizedSubtitle: "Message us to learn the unsubscribe process.",
            icon: UIApplicationShortcutIcon(type: .mail),
            userInfo: nil
        )
        UIApplication.shared.shortcutItems = [shortcutItem]
    }
}
