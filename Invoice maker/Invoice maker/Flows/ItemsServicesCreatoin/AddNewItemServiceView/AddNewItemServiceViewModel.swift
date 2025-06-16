import SwiftUI

final class AddNewItemServiceViewModel: ObservableObject {
    @Published var nameError = false
    @Published var priceError = false
    
    @Published var itemServiceInput: ItemServiceInput
    
    @Published var isExpanded: Bool = false
    @Published var showLeaveWithoutSavingAlert = false
    
    let nameFieldTitle: String
    let titleButtonTitle: String
    let alertLeavewithoutSavingMessage: String
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared, offerType: SegmentOfferType) {
        self.coreDataManager = coreDataManager
        self.nameFieldTitle = offerType == .items ? "Item name" : "Service name"
        self.titleButtonTitle = offerType == .items ? "Add new item" : "Add new service"
        self.alertLeavewithoutSavingMessage =  "If you close this \(offerType == .items ? "item" : "service"), all changes will be lost."
        self.itemServiceInput = .init(
            isItem: offerType == .items,
            name: "",
            price: "",
            quantity: "1",
            discountType: .none,
            discount: "",
            tax: ""
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
            try await coreDataManager.createItemOrService(
                input: itemServiceInput
            )
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
