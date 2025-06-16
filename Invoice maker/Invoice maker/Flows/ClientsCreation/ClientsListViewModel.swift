import SwiftUI
import Combine

final class ClientsListViewModel: ObservableObject {
    @Published var clients: [ClientEntity] = []
    @Published var isShowDeleteAlert = false
    @Published var showErrorAlert = false
    @Published var errorAlertSubtitle = ""
    @Published var clientToDelete: ClientEntity? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setSubscription()
    }
    
    @MainActor
    func fetchClients() async {
        do {
            let fetched = try await CoreDataManager.shared.fetchClients()
            self.clients = fetched
        } catch let error {
            showErrorAlert = true
            errorAlertSubtitle = error.localizedDescription
        }
    }
    
    func deleteClient(_ client: ClientEntity) async {
        do {
            try await CoreDataManager.shared.deleteClient(client)
            await fetchClients()
        } catch {
            showErrorAlert = true
            errorAlertSubtitle = error.localizedDescription
        }
    }
    
    func showDeleteAlert(for client: ClientEntity) {
        isShowDeleteAlert = true
        clientToDelete = client
    }
    
    private func setSubscription() {
        CoreDataManager.shared.$updateClients
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                Task {
                    await self?.fetchClients()
                }
            }
            .store(in: &cancellables)
    }
}
