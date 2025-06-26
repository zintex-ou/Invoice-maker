import SwiftUI

final class AddNewItemServiceViewModel: ObservableObject {
    @Published var nameError = false
    @Published var priceError = false
    
    @Published var itemServiceInput: ItemServiceInput
    
    @Published var isExpanded: Bool = false
    @Published var showLeaveWithoutSavingAlert = false
    
    @Published var showErrorAlert = false
    @Published var errorAlertSubtitle = ""
    
    let nameFieldTitle: String
    let titleButtonTitle: String
    let alertLeavewithoutSavingMessage: String
    let subtitle1: String
    let subtitle2: String
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared, offerType: SegmentOfferType) {
        self.coreDataManager = coreDataManager
        self.nameFieldTitle = offerType == .items ? "Item name" : "Service name"
        self.titleButtonTitle = offerType == .items ? "Add new item" : "Add new service"
        self.alertLeavewithoutSavingMessage =  "If you close this \(offerType == .items ? "item" : "service"), all changes will be lost."
        self.subtitle1 = offerType == .items ? "Item info" : "Service info"
        self.subtitle2 = offerType == .items ? "Item price" : "Service price"
        self.itemServiceInput = .init(
            id: .init(),
            isItem: offerType == .items,
            name: "",
            price: "",
            quantity: "1",
            discountType: .none,
            discount: "",
            tax: "",
            currency: .USD
        )
    }
    
    var hasChanges: Bool {
        !itemServiceInput.name.isEmpty && !itemServiceInput.price.isEmpty
    }
    
    func validateFields() -> Bool {
        nameError = itemServiceInput.name.isEmpty
        priceError = itemServiceInput.price.isEmpty
        return nameError || priceError
    }
    
    func saveClient() {
        Task {
            do {
                let item = try await coreDataManager.createItemOrService(
                    input: itemServiceInput
                )
                
                NotificationService.shared.post(event: .updateItemsServices, object: item)
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
