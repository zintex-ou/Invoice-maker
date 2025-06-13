import SwiftUI
import Combine

final class EditClientViewModel: ObservableObject {
    @Published var nameError = false
    @Published var eMailError = false
    
    @Published var clientInput: ClientInput
    
    @Published var isExpanded: Bool = false
    @Published var isShowDeleteAlert: Bool = false
    @Published var showLeaveWithoutSavingAlert: Bool = false
    
    private var client: ClientEntity
    
    let coreDataManager: CoreDataManager
    
    init(client: ClientEntity,
         coreDataManager: CoreDataManager = .shared) {
        self.client = client
        self.clientInput = .init(
            clientName: client.clientName ?? "",
            email: client.email ?? "",
            phoneNumber: client.phoneNumber ?? "",
            fax: client.fax ?? "",
            country: client.country ?? "",
            city: client.city ?? "",
            street: client.street ?? "",
            apartment: client.apartment ?? "",
            postalCode: client.postalCode ?? ""
        )
        
        self.coreDataManager = coreDataManager
    }
    
    var hasChanges: Bool {
        [
            clientInput.clientName,
            clientInput.email,
            clientInput.phoneNumber,
            clientInput.fax,
            clientInput.country,
            clientInput.city,
            clientInput.street,
            clientInput.apartment,
            clientInput.postalCode
        ] != [
            client.clientName,
            client.email,
            client.phoneNumber,
            client.fax,
            client.country,
            client.city,
            client.street,
            client.apartment,
            client.postalCode
        ]
    }
    
    func validateFields() -> Bool {
        nameError = clientInput.clientName.isEmpty
        eMailError = clientInput.email.isEmpty
        return nameError || eMailError
    }
    
    func updateClient() {
        Task {
            try await coreDataManager.updateClient(client,
                                                   input: clientInput
            )
        }
    }
    
    func onCloseTapped(completion: @escaping (() -> Void)) {
        if hasChanges {
            showLeaveWithoutSavingAlert = true
        } else {
          completion()
        }
    }
    
    func onSaveTapped(completion: @escaping (() -> Void)) {
        if !validateFields() {
            updateClient()
            completion()
        }
    }
    
    func showDeleteAlert() {
        isShowDeleteAlert = true
    }
    
    func deleteClient() {
        Task {
            try await coreDataManager.deleteClient(client)
        }
    }
}
