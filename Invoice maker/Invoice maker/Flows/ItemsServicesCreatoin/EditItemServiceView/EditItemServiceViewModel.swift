import SwiftUI
import Combine

final class EditItemServiceViewModel: ObservableObject {
    @Published var nameError = false
    @Published var priceError = false
    
    @Published var itemServiceInput: ItemServiceInput
    
    @Published var isExpanded: Bool = false
    @Published var isShowDeleteAlert: Bool = false
    @Published var showLeaveWithoutSavingAlert: Bool = false
    
    private var itemService: ItemServiceEntity
    
    let coreDataManager: CoreDataManager
    let nameFieldTitle: String
    let title: String
    let alertLeavewithoutSavingMessage: String
    let deleteAlertTitle: String
    let deleteAlertMassage: String
    
    init(itemService: ItemServiceEntity,
         coreDataManager: CoreDataManager = .shared) {
        self.itemService = itemService
        self.nameFieldTitle = itemService.isItem ? "Item name" : "Service name"
        self.title = itemService.isItem ? "Edit item" : "Edit service"
        self.alertLeavewithoutSavingMessage =  "If you close this \(itemService.isItem ? "item" : "service"), all changes will be lost."
        self.deleteAlertTitle = "Delete \(itemService.isItem ? "item" : "service")"
        self.deleteAlertMassage = "Are you sure you want to delete this \(itemService.isItem ? "item" : "service")?"
        self.itemServiceInput = .init(
            isItem: itemService.isItem,
            name: itemService.name ?? "",
            price: itemService.price ?? "",
            quantity: itemService.quantity ?? "1",
            discountType: DiscountType(rawValue: itemService.discountType ?? "None") ?? .none,
            discount: itemService.discount ?? "0",
            tax: itemService.tax ?? "0"
        )
        
        self.coreDataManager = coreDataManager
    }
    
    var hasChanges: Bool {
        [
            itemServiceInput.name,
            itemServiceInput.price,
            itemServiceInput.quantity,
            itemServiceInput.discountType.rawValue,
            itemServiceInput.discount,
            itemServiceInput.tax
        ] != [
            itemService.name,
            itemService.price,
            itemService.quantity,
            itemService.discountType,
            itemService.discount,
            itemService.tax
        ]
    }
    
    func validateFields() -> Bool {
        nameError = itemServiceInput.name.isEmpty
        priceError = itemServiceInput.price.isEmpty
        return nameError || priceError
    }
    
    func updateItemService() {
        Task {
            try await coreDataManager.updateItemOrService(itemService,
                                                          input: itemServiceInput
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
            updateItemService()
            completion()
        }
    }
    
    func showDeleteAlert() {
        isShowDeleteAlert = true
    }
    
    func deleteItemService() {
        Task {
            try await coreDataManager.deleteItemOrService(itemService)
        }
    }
}
