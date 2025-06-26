import SwiftUI

final class InvoicesViewModel: ObservableObject {
    @Published var isPremium: Bool = false
    private let userDefaultsPDFService = UserDefaultsPDFService()

    init() {}
}
