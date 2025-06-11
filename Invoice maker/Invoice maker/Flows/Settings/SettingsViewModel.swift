import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var isPremium: Bool = false

    private let feedbackGenerator = FeedbackGenerator.shared

    init() {}
}

extension SettingsViewModel {
    func tapOnSettingsButton(type: SettingType) {
        switch type {
        case .share: shareApp()
        case .contact: contactUs()
        case .privacy: openPrivacy()
        case .terms: openTerms()
        case .restore: restore()
        default: feedbackGenerator.getFeedback()
        }
    }
}

private extension SettingsViewModel {
    private func shareApp() {
        // TODO: Change AppURL
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

    private func restore() {
        feedbackGenerator.getFeedback()
        // TODO: todo
        print("restore")
    }
}
