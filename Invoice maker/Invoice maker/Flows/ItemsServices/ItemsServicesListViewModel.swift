import Foundation
import Combine

@MainActor
final class ItemsServicesListViewModel: ObservableObject {
    @Published var items: [ItemServiceEntity] = []
    @Published var services: [ItemServiceEntity] = []
    @Published var isShowDeleteAlert = false
    @Published var shouldShowAlert = false
    @Published var itemToDelete: ItemServiceEntity? = nil
    @Published var offerSelection: SegmentOfferType = .items
    @Published var selectedItemService: [ItemServiceEntity] = []
    
    private(set) var viewType: ItemServiceViewType
    private var cancellables = Set<AnyCancellable>()
    
    var alert: AlertModel = .init(title: "", subtitle: "")
    
    init(viewType: ItemServiceViewType, selectedItemService: [ItemServiceEntity] = []) {
        self.viewType = viewType
        self.selectedItemService = selectedItemService
        
        Task {
            await fetchItemsServices()
        }
        setupSubscription()
    }
    
    func fetchItemsServices() async {
        do {
            let fetched = try await CoreDataManager.shared.fetchItems()
            
//            let filtered: [ItemServiceEntity]
//            switch viewType {
//            case .choiseItemsOrServices(let currency):
//                filtered = fetched.filter { $0.currency == currency.rawValue }
//            case .editItemsOrServices:
//                filtered = fetched
//            }
            
            self.items = fetched.filter(\.isItem)
            self.services = fetched.filter { !$0.isItem }
            
        } catch {
            alert = AlertModel(
                title: "Failed to Load Data",
                subtitle: "Unable to fetch items and services. Please try again."
            )
            shouldShowAlert = true
        }
    }
    
    func deleteItemService(_ item: ItemServiceEntity) {
        Task {
            do {
                try await CoreDataManager.shared.deleteItemOrService(item)
                if offerSelection == .items {
                    items.removeAll(where: {
                        $0.id == item.id
                    })
                } else {
                    services.removeAll(where: {
                        $0.id == item.id
                    })
                }
            } catch {
                alert = AlertModel(
                    title: "Deletion Failed",
                    subtitle: "Unable to delete the \(offerSelection == .items ? "item" : "service"). Please try again."
                )
                shouldShowAlert = true
            }
        }
    }
    
    func isSelectedCell(_ item: ItemServiceEntity) -> Bool {
        selectedItemService.contains(where: { $0.id == item.id })
    }
    
    func showDeleteAlert(for item: ItemServiceEntity) {
        isShowDeleteAlert = true
        itemToDelete = item
    }
    
    func buttonTitle() -> String {
        "Add new \(offerSelection == .items ? "item" : "service")"
    }
    
    func alertDeleteTitle() -> String {
        "Delete \(offerSelection == .items ? "item" : "service")"
    }
    
    func alertDeleteMessage() -> String {
        "Are you sure you want to delete this \(offerSelection == .items ? "item" : "service")"
    }
    
    func postSelectedItemService(_ item: ItemServiceEntity) {
        NotificationService.shared.post(event: .selectedItemService, object: item)
    }
    
    private func setupSubscription() {
        NotificationService.shared.observe(event: .createItemService) { [weak self] object in
            guard let self = self else { return }
            
            if let object = object as? ItemServiceEntity {
                switch self.viewType {
                case .choiseItemsOrServices(let currency):
                    guard object.currency == currency.rawValue else { return }
                case .editItemsOrServices:
                    break
                }
                
                if object.isItem {
                    self.items.append(object)
                } else {
                    self.services.append(object)
                }
            } else {
                Task {
                    await self.fetchItemsServices()
                }
            }
        }
        
        NotificationService.shared.observe(event: .updateItemsServices) { [weak self] object in
            guard let self = self else { return }
            
            if let object = object as? ItemServiceEntity {
                var currentArray = object.isItem ? self.items : self.services
                
                if let index = currentArray.firstIndex(where: { $0.id == object.id }) {
                    switch self.viewType {
                    case .choiseItemsOrServices(let currency):
                        if object.currency == currency.rawValue {
                            currentArray[index] = object
                        } else {
                            currentArray.remove(at: index)
                        }
                    case .editItemsOrServices:
                        currentArray[index] = object
                    }
                } else {
                    switch self.viewType {
                    case .choiseItemsOrServices(let currency):
                        if object.currency == currency.rawValue {
                            currentArray.append(object)
                        }
                    case .editItemsOrServices:
                        currentArray.append(object)
                    }
                }
                
                if object.isItem {
                    self.items = currentArray
                } else {
                    self.services = currentArray
                }
                
            } else {
                Task {
                    await self.fetchItemsServices()
                }
            }
        }
        
        NotificationService.shared.observe(event: .deleteItemService) { [weak self] object in
            guard let self = self else { return }
            
            if let object = object as? ItemServiceEntity {
                selectedItemService.removeAll(where: { $0.id == object.id })
            } else {
                Task {
                    await self.fetchItemsServices()
                }
            }
        }
    }
    
    func tapOnItemService(_ item: ItemServiceEntity) -> Bool {
        switch viewType {
        case .choiseItemsOrServices(let currency):
            guard item.currency == currency.rawValue else {
                alert = AlertModel(
                    title: "Currency mismatch",
                    subtitle: "This item has \(item.currency ?? "-") currency, but invoice currency is \(currency.rawValue)."
                )
                shouldShowAlert = true
                return false
            }
            return true

        case .editItemsOrServices:
            return true
        }
    }
}
