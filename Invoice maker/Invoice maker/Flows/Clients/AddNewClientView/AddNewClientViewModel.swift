import SwiftUI

final class AddNewClientViewModel: ObservableObject {
    enum ViewState {
        case initial
        case editing(client: ClientEntity)
    }
    
    @Published var nameError = false
    @Published var eMailError = false
    
    @Published var clientName = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var fax = ""
    @Published var country = ""
    @Published var city = ""
    @Published var street = ""
    @Published var apartment = ""
    @Published var postalCode = ""
    
    @Published var isExpanded: Bool = false
    @Published var showLeaveWithoutSavingAlert = false
    @Published var showErrorAlert = false
    @Published var errorAlertSubtitle = ""
    @Published var isShowDeleteAlert: Bool = false
    
    let viewState: ViewState
    let title: String
    let buttonTitle: String
    
    private var hasChanges: Bool {
        !clientName.isEmpty && !email.isEmpty
    }
    
    let coreDataManager: CoreDataManager
    
    init(
        coreDataManager: CoreDataManager = .shared,
        viewState: ViewState
    ) {
        self.coreDataManager = coreDataManager
        self.viewState = viewState
        
        let isInitial = {
            if case .initial = viewState { return true }
            else { return false }
        }()
        
        self.title = isInitial ? "Add new client" : "Edit client"
        self.buttonTitle = isInitial ? "Add new client" : "Save"
        
        if case let .editing(client: client) = viewState {
            fetchClient(client: client)
        }
    }
    
    private func fetchClient(client: ClientEntity) {
        clientName = client.clientName ?? ""
        email = client.email ?? ""
        phoneNumber = client.phoneNumber ?? ""
        fax = client.fax ?? ""
        country = client.country ?? ""
        city = client.city ?? ""
        street = client.street ?? ""
        apartment = client.apartment ?? ""
        postalCode = client.postalCode ?? ""
    }
    
    private func validateFields() -> Bool {
        nameError = clientName.isEmpty
        eMailError = email.isEmpty
        return nameError || eMailError
    }
    
    private func saveClient() {
        Task {
            do {
                let client = try await coreDataManager.createClient(
                    input: .init(
                        id: .init(),
                        clientName: clientName,
                        email: email,
                        phoneNumber: phoneNumber,
                        fax: fax,
                        country: country,
                        city: city,
                        street: street,
                        apartment: apartment,
                        postalCode: postalCode
                    )
                )
                
                NotificationService.shared.post(event: .updateClients, object: client)
            } catch let error {
                showErrorAlert = true
                errorAlertSubtitle = error.localizedDescription
            }
        }
    }
    
    private func onSaveNewClientTapped(completion: @escaping (() -> Void)) {
        if !validateFields() {
            saveClient()
            completion()
        }
    }
    
    func onCloseTapped(completion: @escaping (() -> Void)) {
        if hasAnyChanges {
            showLeaveWithoutSavingAlert = true
        } else {
            completion()
        }
    }
}

extension AddNewClientViewModel {
    private var hasEditedChanges: Bool {
        [
            clientName,
            email,
            phoneNumber,
            fax,
            country,
            city,
            street,
            apartment,
            postalCode
        ] != [
            clientName,
            email,
            phoneNumber,
            fax,
            country,
            city,
            street,
            apartment,
            postalCode
        ]
    }
    
    private func updateClient() {
        if case let .editing(client: client) = viewState {
            Task {
                do {
                    try await coreDataManager.updateClient(
                        client,
                        input: .init(
                            id: .init(),
                            clientName: clientName,
                            email: email,
                            phoneNumber: phoneNumber,
                            fax: fax,
                            country: country,
                            city: city,
                            street: street,
                            apartment: apartment,
                            postalCode: postalCode
                        )
                    )
                } catch let error {
                    showErrorAlert = true
                    errorAlertSubtitle = error.localizedDescription
                }
            }
        }
    }
    
    private var hasAnyChanges: Bool {
        switch viewState {
        case .initial:      return hasChanges
        case .editing(_):   return hasEditedChanges
        }
    }
    
    func onSaveTapped(completion: @escaping (() -> Void)) {
        switch viewState {
        case .editing(_):
            onSaveEditedTapped(completion: completion)
        case .initial:
            onSaveNewClientTapped(completion: completion)
        }
    }
    
    private func onSaveEditedTapped(completion: @escaping (() -> Void)) {
        if !validateFields() {
            updateClient()
            completion()
        }
    }
    
    func showDeleteAlert() {
        isShowDeleteAlert = true
    }
    
    func deleteClient() {
        if case let .editing(client: client) = viewState {
            Task {
                do {
                    let id = client.id
                    try await coreDataManager.deleteClient(client)
                    NotificationService.shared.post(event: .updateClients, object: id)
                } catch let error {
                    showErrorAlert = true
                    errorAlertSubtitle = error.localizedDescription
                }
            }
        }
    }
}
