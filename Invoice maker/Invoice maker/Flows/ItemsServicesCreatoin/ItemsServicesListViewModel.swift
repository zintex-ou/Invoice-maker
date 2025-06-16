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
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
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
        } catch {
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
    
    private func setSubscription() {
        CoreDataManager.shared.$updateItemsServices
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                Task {
                    await self?.fetchItemsServices()
                }
            }
            .store(in: &cancellables)
    }
}
