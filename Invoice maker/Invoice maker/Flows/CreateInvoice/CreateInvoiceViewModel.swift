import Foundation
import Combine

final class CreateInvoiceViewModel: ObservableObject {
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
    
    private(set) var viewType: InvoiceViewType
    private let dataBaseManager: CoreDataManager = .shared
    private var invoiceId: UUID? = nil
    private var pdfPath: URL? = nil
    private var bussinesProfile: BusinessProfileEntity? = nil
    private var cancellables = Set<AnyCancellable>()
    
    var errorText: String = "No items added. To create an invoice, please сlick the “Add item & service” button and fill in the item details."
    
    init(viewType: InvoiceViewType) {
        self.viewType = viewType
        
        configureInitialValues(from: viewType)
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
        switch viewType {
        case .createInvoice, .editInvoice:
            guard dueDate.isSameOrAfterDateIgnoringTime(invoiceDate) else {
                showError("The due date must be the same or later than the invoice date.")
                return
            }
        default:
            break
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

    private func createChooseTemplateInvoiceModel() -> ChooseTemplateInvoiceModel? {
        guard let client = client else {
            return nil
        }
        
        return ChooseTemplateInvoiceModel(
            id: invoiceId ?? .init(),
            client: client,
            number: invoiceNumber,
            invoiceDate: invoiceDate,
            dueDate: dueDate,
            currency: currency.rawValue,
            discount: discount,
            tax: tax,
            subtotal: getSubTotalPrice(),
            total: getTotalPrice(),
            itemOrServices: itemServices,
            pdfPath: pdfPath
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
            guard let self = self else { return }
            
            if let object = object as? ClientEntity {
                self.client = object
            }
        }
        
        NotificationService.shared.observe(event: .selectedItemService) { [weak self] object in
            guard let self = self else { return }
            
            if let object = object as? ItemServiceEntity {
                if !(self.itemServices.contains(where: { $0.id == object.id })) {
                    self.itemServices.append(object)
                }
            }
        }
        
        NotificationService.shared.observe(event: .updateItemsServices) { [weak self] object in
            guard let self,
                  let object = object as? ItemServiceEntity else { return }
            
            if let index = self.itemServices.firstIndex(where: { $0.id == object.id }) {
                if self.currency.rawValue == object.currency {
                    self.itemServices[index] = object
                } else {
                    self.itemServices.remove(at: index)
                }
            }
        }
        
        NotificationService.shared.observe(event: .deleteItemService) { [weak self] object in
            guard let self = self else { return }
            
            if let object = object as? ItemServiceEntity {
                itemServices.removeAll(where: { $0.id == object.id })
            }
        }
        
        $currency
            .dropFirst()
            .sink { [weak self] _ in
                self?.itemServices.removeAll()
            }
            .store(in: &cancellables)
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
    
    private func configureInitialValues(from viewType: InvoiceViewType) {
        switch viewType {
        case let .editInvoice(invoice), let .editEstimate(invoice):
            self.invoiceId = invoice.id
            self.invoiceNumber = invoice.invoiceNumber ?? "1"
            self.currency = Currency(from: invoice.currency)
            self.invoiceDate = invoice.invoiceDate ?? Date()
            self.dueDate = invoice.dueDate ?? Date()
            self.client = invoice.client
            if let itemSet = invoice.itemService as? Set<ItemServiceEntity> {
                self.itemServices = Array(itemSet)
            } else {
                self.itemServices = []
            }
            self.discount = invoice.discount ?? "0"
            self.tax = invoice.tax ?? "0"
            self.pdfPath = invoice.pdfFilePath
        default:
            break
        }
    }
}
