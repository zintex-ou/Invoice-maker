import SwiftUI

final class EstimatesViewModel: ObservableObject {
    @Published var isPremium: Bool = false
    private let userDefaultsPDFService = UserDefaultsPDFService()

    init() {}
}
