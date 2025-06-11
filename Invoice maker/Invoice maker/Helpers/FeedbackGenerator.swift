import SwiftUI

final class FeedbackGenerator {
    static let shared = FeedbackGenerator()

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    private init() {
        feedbackGenerator.prepare()
    }

    func getFeedback(_ intensity: CGFloat = 0.2) {
        feedbackGenerator.impactOccurred(intensity: intensity)
    }
}
