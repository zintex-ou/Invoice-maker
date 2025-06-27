import Foundation

final class CreateInvoiceViewModel: ObservableObject {
    enum ViewType {
        case createInvoice
        case createEstimate
        case editInvoice
        case editEstimate
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
    
    private(set) var viewType: ViewType
    private let dataBaseManager: CoreDataManager = .shared
    private var bussinesProfile: BusinessProfileEntity? = nil
    
    var errorText: String = "No items added. To create an invoice, please сlick the “Add item & service” button and fill in the item details."
    
    init(viewType: ViewType) {
        self.viewType = viewType
        setSubscription()
        fetchBussinessProfile()
    }
    
    func getTopTitle() -> String {
        switch viewType {
        case .createInvoice:
            return "New Invoice"
        case .createEstimate:
            return "New Estimate"
        case .editInvoice:
            return "Edit Invoice"
        case .editEstimate:
            return "Edit Estimate"
        }
    }
    
    func getInfoTitle() -> String {
        switch viewType {
        case .createEstimate:
            return "Estimate info"
        default:
            return "Invoice info"
        }
    }
    
    func getNumberTitle() -> String {
        switch viewType {
        case .createEstimate:
            return "Estimate number"
        default:
            return "Invoice number"
        }
    }
    
    func getDateTitle() -> String {
        switch viewType {
        case .createEstimate:
            return "Estimate date"
        default:
            return "Invoice date"
        }
    }
    
    func getButtonTitle() -> String {
        switch viewType {
        case .createEstimate:
            return "Create Estimate"
        default:
            return "Create Invoice"
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
    
    func tapOnCreateInvoiceButton(completion: @escaping (ChooseTemplateInvoiceModel?) -> Void) {
        if viewType == .createInvoice || viewType == .editInvoice {
            guard dueDate.isSameOrAfterDateIgnoringTime(invoiceDate) else {
                showError("The due date must be the same or later than the invoice date.")
                return
            }
        }
        
        guard let bussinesProfile = bussinesProfile,
              let ownerName = bussinesProfile.ownerName, !ownerName.isEmpty,
              let email = bussinesProfile.email, !email.isEmpty else {
            showError("Please complete your business profile by providing both your name and email address.")
            return
        }
        
        guard client != nil else {
            showError("Please select a client before creating the invoice.")
            return
        }
        
        guard !itemServices.isEmpty else {
            showError("No items added. To create an invoice, please сlick the “Add item & service” button and fill in the item details.")
            return
        }
        
        completion(createChooseTemplateInvoiceModel())
    }
    
    func getInvoiceType() -> InvoiceType {
        let type = (viewType == .createEstimate || viewType == .editEstimate) ? InvoiceType.estimate : InvoiceType.invoice
        return type
    }
    
    private func createChooseTemplateInvoiceModel() -> ChooseTemplateInvoiceModel? {
        guard let client = client else {
            return nil
        }
        
        return ChooseTemplateInvoiceModel(
            client: client,
            number: invoiceNumber,
            invoiceDate: invoiceDate,
            dueDate: dueDate,
            currency: currency.rawValue,
            discount: discount,
            tax: tax,
            subtotal: getSubTotalPrice(),
            total: getTotalPrice(),
            itemOrServices: itemServices
        )
    }
    
    func shouldShowDiscountAndTax() {
        shouldShowDiscountTax.toggle()
    }
    
    func getSubTotalPrice() -> Double {
        guard !itemServices.isEmpty else {
            return 0.0
        }
        
        let price = itemServices.reduce(into: 0.0) { result, itemService in
            let price = itemService.total
            result += Double(price ?? "0") ?? 0
        }
        
        return price
    }
    
    func getTotalPrice() -> Double {
        let subTotalPrice = getSubTotalPrice()
        
        var totalPrice = subTotalPrice
        
        if let discountPercent = Double(discount), discountPercent > 0 {
            totalPrice -= (subTotalPrice * discountPercent / 100)
        }
        
        if totalPrice < 0 {
            totalPrice = 0
        }
        
        if let taxPercent = Double(tax), taxPercent > 0 {
            totalPrice += (totalPrice * taxPercent / 100)
        }
        
        return totalPrice
    }
    
    private func setSubscription() {
        NotificationService.shared.observe(event: .selectedClient) { [weak self] object in
            if let object = object as? ClientEntity {
                self?.client = object
            }
        }
        
        NotificationService.shared.observe(event: .selectedItemService) { [weak self] object in
            if let object = object as? ItemServiceEntity {
                if !(self?.itemServices.contains(where: { $0.id == object.id }) ?? true) {
                    self?.itemServices.append(object)
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        errorText = message
        shouldShowErrorView = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.shouldShowErrorView = false
        }
    }
    
    private func fetchBussinessProfile() {
        Task {
            do {
                guard let result = try await dataBaseManager.fetchBusinessProfile() else { return }
                self.bussinesProfile = result
            } catch {
                
            }
        }
    }
}
