import SwiftUI

final class TabBarViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var isPremium: Bool = false
    @Published var showSentPopup = false

    init() {
        setSubscription()
    }

    func tapOnTabBarItem(at index: Int) {
        FeedbackGenerator.shared.getFeedback()
        selectedIndex = index
    }
    
    private func setSubscription() {
        NotificationService.shared.observe(event: .sentMailSuccessfully) { [weak self] object in
            if let object = object as? Bool {
                self?.showSentPopup = object
            }
        }
    }
}
