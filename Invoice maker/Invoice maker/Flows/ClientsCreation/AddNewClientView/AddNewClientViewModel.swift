import SwiftUI

final class AddNewClientViewModel: ObservableObject {
    @Published var clientName: String = ""
    @Published var nameError = false
    @Published var eMail = ""
    @Published var eMailError = false
    @Published var phoneNumber = ""
    @Published var fax = ""
    @Published var country = ""
    @Published var city: String = ""
    @Published var street: String = ""
    @Published var apartment: String = ""
    @Published var postalCode: String = ""
    
    @Published var isAllFields: Bool = false
    
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    func validateFields() -> Bool {
        nameError  = clientName.isEmpty
        eMailError = eMail.isEmpty
        return nameError || eMailError
    }
    
    func saveClient() {
        Task {
            try await coreDataManager.createClient(
                input: .init(
                    clientName: clientName,
                    email: eMail,
                    phoneNumber: phoneNumber,
                    fax: fax,
                    country: country,
                    city: city,
                    street: street,
                    apartment: apartment,
                    postalCode: postalCode
                )
            )
        }
    }
}
