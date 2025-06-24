import SwiftUI
import Combine

final class ItemsServicesListViewModel: ObservableObject {
    @Published var items: [ItemServiceEntity] = []
    @Published var services: [ItemServiceEntity] = []
    @Published var isShowDeleteAlert = false
    @Published var showErrorAlert = false
    @Published var errorAlertSubtitle = ""
    @Published var itemToDelete: ItemServiceEntity? = nil
    @Published var offerSelection: SegmentOfferType = .items
    
    enum ViewType {
        case choiseItemsOrServices
        case editItemsOrServices
    }
    
    let viewType: ViewType
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewType: ViewType) {
        self.viewType = viewType
        setSubscription()
    }
    
    @MainActor
    func fetchItemsServices() async {
        do {
            let fetched = try await CoreDataManager.shared.fetchItems()
            
            self.items = fetched.filter { $0.isItem == true }
            self.services = fetched.filter { $0.isItem == false }
        } catch let error {
            showErrorAlert = true
            errorAlertSubtitle = error.localizedDescription
        }
    }
    
    func deleteItemService(_ item: ItemServiceEntity) async {
        do {
            try await CoreDataManager.shared.deleteItemOrService(item)
            await fetchItemsServices()
        } catch let error {
            showErrorAlert = true
            errorAlertSubtitle = error.localizedDescription
        }
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
    
    private func setSubscription() {
        NotificationService.shared.observe(event: .updateItemsServices) { [weak self] object in
            if let object = object as? ItemServiceEntity {
                if object.isItem {
                    self?.items.append(object)
                } else {
                    self?.services.append(object)
                }
            } else {
                Task {
                    await self?.fetchItemsServices()
                }
            }
        }
    }
}
