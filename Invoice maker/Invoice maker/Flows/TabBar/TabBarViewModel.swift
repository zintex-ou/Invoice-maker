import SwiftUI

final class TabBarViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var isPremium: Bool = false

    init() {}

    func tapOnTabBarItem(at index: Int) {
        FeedbackGenerator.shared.getFeedback()
        selectedIndex = index
    }
}
