import SwiftUI

final class AddNewItemServiceViewModel: ObservableObject {
    enum ViewState {
        case editing(entity: ItemServiceEntity)
        case initial
    }
    @Published var nameError = false
    @Published var priceError = false
    
    @Published var name: String = ""
    @Published var price: String = ""
    @Published var quantity: String = "1"
    @Published var discountType: DiscountType = .none
    @Published var discount: String = "0"
    @Published var tax: String = "0"
    @Published var currency: Currency = .USD
    
    @Published var sholdShowCurrencyPicker: Bool = false
    @Published var isExpanded: Bool = false
    @Published var showLeaveWithoutSavingAlert = false
    
    @Published var showErrorAlert = false
    @Published var errorAlertSubtitle = ""
    @Published var isDiscountPopShow = false
    @Published var isShowDeleteAlert = false
    
    let nameFieldTitle: String
    let title: String
    let buttonTitle: String
    let alertLeavewithoutSavingMessage: String
    let subtitle1: String
    let subtitle2: String
    let coreDataManager: CoreDataManager
    let viewState: ViewState
    let offerType: SegmentOfferType
    let deleteAlertTitle: String
    let deleteAlertMassage: String
    
    init(
        coreDataManager: CoreDataManager = .shared,
        offerType: SegmentOfferType,
        viewState: ViewState
    ) {
        self.coreDataManager = coreDataManager
        self.nameFieldTitle = offerType == .items ? "Item name" : "Service name"
       let isItem = offerType == .items
        
        var titlePart: String {
            switch viewState {
            case .initial:   return "Add"
            case .editing:   return "Edit"
            }
        }
        
        let isInitial = {
            if case .initial = viewState { return true }
            else { return false }
        }()
        
        self.title = offerType == .items ? "\(titlePart) item" : "\(titlePart) service"
        self.buttonTitle = isInitial ? (isItem ? "Add new item" : "Add new service") : "Save"
        self.alertLeavewithoutSavingMessage =  "If you close this \(isItem ? "item" : "service"), all changes will be lost."
        self.subtitle1 = isItem ? "Item info" : "Service info"
        self.subtitle2 = isItem ? "Item price" : "Service price"
        self.deleteAlertTitle = "Delete \(isItem ? "item" : "service")"
        self.deleteAlertMassage = "Are you sure you want to delete this \(isItem ? "item" : "service")?"
        self.viewState = viewState
        self.offerType = offerType
        
        if case let .editing(entity: item) = viewState {
            fetchItemService(item: item)
        }
    }
    
    var hasChanges: Bool {
        !name.isEmpty && !price.isEmpty
    }
    
    func validateFields() -> Bool {
        nameError = name.isEmpty
        priceError = price.isEmpty
        return nameError || priceError
    }
    
    func tapOnCurrencyButton() {
        sholdShowCurrencyPicker = true
    }
    
    func saveItemService() {
        Task {
            do {
                let item = try await coreDataManager.createItemOrService(
                    input: .init(
                        id: .init(),
                        isItem: offerType == .items,
                        name: name,
                        price: price,
                        quantity: quantity,
                        discountType: discountType,
                        discount: discount,
                        tax: tax,
                        currency: currency
                    )
                )
                
                NotificationService.shared.post(event: .createItemService, object: item)
            } catch let error {
                showErrorAlert = true
                errorAlertSubtitle = error.localizedDescription
            }
        }
    }
    
    func onSaveTapped(completion: @escaping (() -> Void)) {
        switch viewState {
        case .editing(_):
            onSaveEditedTapped(completion: completion)
        case .initial:
            onSaveNewItemTapped(completion: completion)
        }
    }
    
   private func onSaveNewItemTapped(completion: @escaping (() -> Void)) {
        if !validateFields() {
            saveItemService()
            completion()
        }
    }
    
    private var hasAnyChanges: Bool {
        switch viewState {
        case .initial:      return hasChanges
        case .editing(_):   return hasEditedChanges
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

extension AddNewItemServiceViewModel {
    private func fetchItemService(item: ItemServiceEntity) {
        name = item.name ?? ""
        price = item.price ?? ""
        quantity = item.quantity ?? ""
        discountType = .init(rawValue: item.discountType ?? "none") ?? .none
        discount = item.discount ?? ""
        tax = item.tax ?? ""
        currency = .init(rawValue: item.currency ?? "USD") ?? .USD
    }
    
    private var hasEditedChanges: Bool {
        [
            name,
            price,
            quantity,
            discountType.rawValue,
            discount,
            tax
        ] != [
            name,
            price,
            quantity,
            discountType.rawValue,
            discount,
            tax
        ]
    }
    
   private func updateItemService() {
       if case let .editing(entity: item) = viewState {
            Task {
                do {
                   let item = try await coreDataManager.updateItemOrService(
                        item,
                        input: .init(
                            id: .init(),
                            isItem: offerType == .items,
                            name: name,
                            price: price,
                            quantity: quantity,
                            discountType: discountType,
                            discount: discount,
                            tax: tax,
                            currency: currency
                        )
                    )
                    
                    NotificationService.shared.post(event: .updateItemsServices, object: item)
                } catch let error {
                    showErrorAlert = true
                    errorAlertSubtitle = error.localizedDescription
                }
            }
        }
    }
    
   private func onSaveEditedTapped(completion: @escaping (() -> Void)) {
        if !validateFields() {
            updateItemService()
            completion()
        }
    }
    
    func showDeleteAlert() {
        isShowDeleteAlert = true
    }
    
    func deleteItemService() {
        if case let .editing(entity: item) = viewState {
            Task {
                do {
                    try await coreDataManager.deleteItemOrService(item)
                    
                    NotificationService.shared.post(event: .deleteItemService, object: item)
                } catch let error {
                    showErrorAlert = true
                    errorAlertSubtitle = error.localizedDescription
                }
            }
        }
    }
}
