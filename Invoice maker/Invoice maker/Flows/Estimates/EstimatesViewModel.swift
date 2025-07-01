import Foundation
import Combine

@MainActor
final class EstimatesViewModel: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var allEstimates: [InvoiceEntity] = []
    @Published var shouldShowAlert: Bool = false
    
    private let dataBaseService = InvoiceDataBaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var alert: AlertModel = .init(title: "", subtitle: "")
    
    init() {
        bindToDataBaseService()
    }
    
    func change(isPaid: Bool, for id: UUID) {
        Task {
            do {
                try await dataBaseService.change(isPaid: isPaid, for: id)
            } catch {
                alert = .init(
                    title: "Failed to Update Status",
                    subtitle: "An error occurred while changing the payment status."
                )
                shouldShowAlert = true
            }
        }
    }
}

extension EstimatesViewModel {
    private func bindToDataBaseService() {
        dataBaseService.$allEstimates
            .assign(to: \.allEstimates, on: self)
            .store(in: &cancellables)
    }
}
