import Foundation

final class CreateInvoiceViewModel: ObservableObject {
    enum ViewType {
        case createInvoice
        case createEstimate
        case edit
    }
    
    @Published var bottomHeight: CGFloat = .zero
    @Published var invoiceNumber: String = "1"
    @Published var currency: Currency = .USD
    @Published var invoiceDate: Date = .now
    @Published var dueDate: Date = .now
    @Published var client: ClientEntity?
    @Published var itemServices: [ItemServiceEntity] = []
    @Published var discount: String = "0"
    @Published var tax: String = "0"
    
    @Published var sholdShowCurrencyPicker: Bool = false
    @Published var showInvoiceDatePicker = false
    @Published var showDueDatePicker = false
    @Published var shouldShowErrorView: Bool = false
    @Published var shouldShowDiscountTax: Bool = false
    @Published var isPresenterDiskont: Bool = false
    
    private let viewType: ViewType
    
    init(viewType: ViewType) {
        self.viewType = viewType
        setSubscription()
    }
    
    func getTopTitle() -> String {
        switch viewType {
        case .createInvoice:
            return "New Invoice"
        case .createEstimate:
            return "New Estimate"
        case .edit:
            return "Edit"
        }
    }
    
    func getCurrency() -> String {
        return currency.rawValue
    }
    
    func tapOnCurrencyButton() {
        sholdShowCurrencyPicker = true
    }
    
    func getInvoiceDate() -> String {
        invoiceDate.formatedDateString
    }
    
    func getDueDate() -> String {
        dueDate.formatedDateString
    }
    
    func tapOnInvoiceDateButton() {
        showInvoiceDatePicker = true
    }
    
    func tapOnDueDateButton() {
        showDueDatePicker = true
    }
    
    func getClientName() -> String {
        client?.clientName ?? "Client"
    }
    
    func deleteItemService(_ itemService: ItemServiceEntity) {
        itemServices.removeAll { $0.id == itemService.id }
    }
    
    func tapOnCreateInvoiceButton() {
        shouldShowErrorView = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.shouldShowErrorView = false
        }
    }
    
    func shouldShowDiscountAndTax() {
        shouldShowDiscountTax.toggle()
    }
    
    private func setSubscription() {
        NotificationService.shared.observe(event: .selectedClient) { [weak self] object in
            if let object = object as? ClientEntity {
                self?.client = object
            }
        }
        
        NotificationService.shared.observe(event: .selectedItemService) { [weak self] object in
            if let object = object as? ItemServiceEntity {
                self?.itemServices.append(object)
            }
        }
    }
}
