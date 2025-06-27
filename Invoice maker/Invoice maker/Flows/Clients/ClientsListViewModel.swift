import SwiftUI
import Combine

final class ClientsListViewModel: ObservableObject {
    @Published var clients: [ClientEntity] = []
    @Published var isShowDeleteAlert = false
    @Published var showErrorAlert = false
    @Published var errorAlertSubtitle = ""
    @Published var clientToDelete: ClientEntity? = nil
    @Published var selectedClient: ClientEntity?
    
    private(set) var viewType: ClientViewType
    private var cancellables = Set<AnyCancellable>()
    
    init(viewType: ClientViewType, selectedClient: ClientEntity? = nil) {
        self.viewType = viewType
        self.selectedClient = selectedClient
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
    
    func postSelectedClient(_ client: ClientEntity) {
        NotificationService.shared.post(event: .selectedClient, object: client)
    }
    
    func isSelected(client: ClientEntity) -> Bool {
        guard let selectedClient else { return false }
        return client.id == selectedClient.id
    }
    
    private func setSubscription() {
        NotificationService.shared.observe(event: .updateClients) { [weak self] object in
            if let object = object as? ClientEntity {
                self?.clients.append(object)
            } else {
                Task {
                    await self?.fetchClients()
                }
            }
        }
    }
}
