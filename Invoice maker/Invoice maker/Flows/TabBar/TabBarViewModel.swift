import SwiftUI

final class TabBarViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0

    init() {}

    func tapOnTabBarItem(at index: Int) {
        FeedbackGenerator.shared.getFeedback()
        selectedIndex = index
    }
}
