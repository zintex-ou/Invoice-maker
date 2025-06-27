import SwiftUI
import Combine

@MainActor
final class EstimatesViewModel: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var allEstimates: [InvoiceEntity] = []
    
    private let dataBaseService = DataBaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindToDataBaseService()
    }
    
    func change(isPaid: Bool, for id: UUID) {
        Task {
            await dataBaseService.change(isPaid: isPaid, for: id)
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
