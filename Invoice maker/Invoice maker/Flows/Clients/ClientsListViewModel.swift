import Foundation
import Combine

@MainActor
final class ClientsListViewModel: ObservableObject {
    @Published var clients: [ClientEntity] = []
    @Published var isShowDeleteAlert = false
    @Published var shouldShowAlert = false
    @Published var clientToDelete: ClientEntity? = nil
    @Published var selectedClient: ClientEntity?
    
    private(set) var viewType: ClientViewType
    private var cancellables = Set<AnyCancellable>()
    
    var alert: AlertModel = .init(title: "", subtitle: "")
    
    init(viewType: ClientViewType, selectedClient: ClientEntity? = nil) {
        self.viewType = viewType
        self.selectedClient = selectedClient
        setSubscription()
    }
    
    func fetchClients() async {
        do {
            let fetched = try await CoreDataManager.shared.fetchClients()
            self.clients = fetched
        } catch let error {
            alert = .init(
                title: "Failed to Fetch Clients",
                subtitle: "An error occurred while trying to load the client list."
            )

            shouldShowAlert = true
        }
    }
    
    func deleteClient(_ client: ClientEntity) async {
        do {
            try await CoreDataManager.shared.deleteClient(client)
            clients.removeAll { $0.id == client.id }
            clientToDelete = nil
        } catch {
            alert = .init(
                title: "Failed to Delete Client",
                subtitle: "An error occurred while trying to delete the selected client."
            )

            shouldShowAlert = true
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
