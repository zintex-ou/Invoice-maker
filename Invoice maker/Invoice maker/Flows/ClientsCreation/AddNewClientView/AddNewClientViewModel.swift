import SwiftUI

final class AddNewClientViewModel: ObservableObject {
    @Published var nameError = false
    @Published var eMailError = false
    
    @Published var clientInput: ClientInput
    
    @Published var isExpanded: Bool = false
    @Published var showLeaveWithoutSavingAlert = false
    @Published var showErrorAlert = false
    @Published var errorAlertSubtitle = ""
    
    private var hasChanges: Bool {
        !clientInput.clientName.isEmpty && !clientInput.email.isEmpty
    }
    
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
        self.clientInput = .init(
            clientName: "",
            email: "",
            phoneNumber: "",
            fax: "",
            country: "",
            city: "",
            street: "",
            apartment: "",
            postalCode: ""
        )
    }
    
    func validateFields() -> Bool {
        nameError = clientInput.clientName.isEmpty
        eMailError = clientInput.email.isEmpty
        return nameError || eMailError
    }
    
    func saveClient() {
        Task {
            do {
                let client = try await coreDataManager.createClient(
                    input: clientInput
                )
                
                NotificationService.shared.post(event: .updateClients, object: client)
            } catch let error {
                showErrorAlert = true
                errorAlertSubtitle = error.localizedDescription
            }
        }
    }
    
    func onSaveTapped(completion: @escaping (() -> Void)) {
        if !validateFields() {
            saveClient()
            completion()
        }
    }
 
    func onCloseTapped(completion: @escaping (() -> Void)) {
        if hasChanges {
            showLeaveWithoutSavingAlert = true
        } else {
          completion()
        }
    }
}
