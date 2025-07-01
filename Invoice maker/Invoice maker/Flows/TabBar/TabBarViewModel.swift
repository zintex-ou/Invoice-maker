import Foundation
import Combine

final class TabBarViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var isPremium: Bool = false
    @Published var showSentPopup = false
    
    private let purchaseManager: PurchaseManager = .shared
    private var cancellable: AnyCancellable?

    init() {
        setSubscription()
    }

    func tapOnTabBarItem(at index: Int) {
        FeedbackGenerator.shared.getFeedback()
        selectedIndex = index
    }
    
    private func setSubscription() {
        cancellable = purchaseManager.isPremium
            .receive(on: RunLoop.main)
            .assign(to: \.isPremium, on: self)
        
        NotificationService.shared.observe(event: .sentMailSuccessfully) { [weak self] object in
            if let object = object as? Bool {
                self?.showSentPopup = object
            }
        }
    }
}
