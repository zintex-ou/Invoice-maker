import Foundation

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
    @Published var bankDetails = ""
    @Published var country = ""
    @Published var city = ""
    @Published var street = ""
    @Published var apartment = ""
    @Published var postalCode = ""
    
    @Published var isExpanded: Bool = false
    @Published var showLeaveWithoutSavingAlert = false
    @Published var shouldShowAlert = false
    @Published var isShowDeleteAlert: Bool = false
    
    var alert: AlertModel = .init(title: "", subtitle: "")
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
        bankDetails = client.bankDetails ?? ""
        country = client.country ?? ""
        city = client.city ?? ""
        street = client.street ?? ""
        apartment = client.apartment ?? ""
        postalCode = client.postalCode ?? ""
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
                        bankDetails: bankDetails,
                        country: country,
                        city: city,
                        street: street,
                        apartment: apartment,
                        postalCode: postalCode
                    )
                )
                
                NotificationService.shared.post(event: .updateClients, object: client)
            } catch {
                self.alert = .init(
                    title: "Failed to Save Client",
                    subtitle: "An error occurred while saving your client. Please try again later."
                )
                shouldShowAlert = true
            }
        }
    }
    
    private func onSaveNewClientTapped(completion: @escaping (() -> Void)) {
        saveClient()
        completion()
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
            bankDetails,
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
            bankDetails,
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
                            bankDetails: bankDetails,
                            country: country,
                            city: city,
                            street: street,
                            apartment: apartment,
                            postalCode: postalCode
                        )
                    )
                } catch {
                    self.alert = .init(
                        title: "Failed to Update Client",
                        subtitle: "An error occurred while updating your client. Please try again later."
                    )
                    shouldShowAlert = true
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
    
    @MainActor
    func onSaveTapped(completion: @escaping () -> Void) {
        guard !clientName.isEmpty else {
            nameError = true
            return
        }

        guard !email.isEmpty else {
            eMailError = true
            return
        }

        guard !clientName.isValidPunctuationAndNewlinesOnly() else {
            alert = .init(
                title: "Invalid Name",
                subtitle: "The name you entered contains only punctuation or spacing characters. Please enter a valid name using letters or numbers."
            )
            shouldShowAlert = true
            return
        }

        guard email.isValidEmail() else {
            alert = .init(
                title: "Invalid Email",
                subtitle: "The email address you provided doesn't match the required format. Please enter a valid email (e.g. name@example.com)."
            )
            shouldShowAlert = true
            return
        }

        Task {
            let input = ClientInput(
                id: .init(),
                clientName: clientName,
                email: email,
                phoneNumber: phoneNumber,
                fax: fax,
                bankDetails: bankDetails,
                country: country,
                city: city,
                street: street,
                apartment: apartment,
                postalCode: postalCode
            )

            do {
                switch viewState {
                case .editing(let client):
                    try await coreDataManager.updateClient(client, input: input)
                case .initial:
                    let client = try await coreDataManager.createClient(input: input)
                    NotificationService.shared.post(event: .updateClients, object: client)
                }
                completion()
            } catch {
                self.alert = .init(
                    title: "Failed to Save Client",
                    subtitle: "An error occurred while saving your client. Please try again later."
                )
                shouldShowAlert = true
            }
        }
    }
    
    private func onSaveEditedTapped(completion: @escaping (() -> Void)) {
        updateClient()
        completion()
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
                } catch {
                    self.alert = .init(
                        title: "Failed to Delete Client",
                        subtitle: "An error occurred while deleting your client. Please try again later."
                    )
                    shouldShowAlert = true
                }
            }
        }
    }
}
