import SwiftUI
import Combine

@MainActor
final class ChooseTemplateViewModel: ObservableObject {
    @Published var templateType: TemplateType = .topDark
    @Published var customColor: CustomColors = .blue
    @Published var templateIndex = 0
    @Published var shouldShowError: Bool = false
    @Published var isShowDeleteAlert: Bool = false
    @Published var isPremium: Bool = false
    
    private let dataBaseService = InvoiceDataBaseService.shared
    private let chooseTemplateInvoiceModel: ChooseTemplateInvoiceModel
    private let viewType: InvoiceViewType
    private let keychainManager = KeychainManager()
    private let purchaseManager: PurchaseManager = .shared
    private var cancellable: AnyCancellable?
    
    var isFreeGeneratedInvoice: Bool {
        get {
            return keychainManager.isFreeGeneratedInvoice ?? true
        }
        set {
            keychainManager.isFreeGeneratedInvoice = newValue
        }
    }
    
    var alert: AlertModel = .init(title: "", subtitle: "")
    var invoiceType: InvoiceType {
        switch viewType {
        case .createInvoice, .editInvoice, .convertEstimateToInvoice:
            return .invoice
        case .createEstimate, .editEstimate:
            return .estimate
        }
    }
    
    init(chooseTemplateInvoiceModel: ChooseTemplateInvoiceModel,
         viewType: InvoiceViewType
    ) {
        self.viewType = viewType
        self.chooseTemplateInvoiceModel = chooseTemplateInvoiceModel
        
        setupSubscriptions()
    }
    
    func onCancelTapped() {
        isShowDeleteAlert = true
    }
    
    func title() -> String {
        switch viewType {
        case .createInvoice:
            return "New Invoice"
        case .createEstimate:
            return "New Estimate"
        case .editInvoice:
            return "Edit Invoice"
        case .editEstimate:
            return "Edit Estimate"
        case .convertEstimateToInvoice:
            return "Convert Estimate"
        }
    }
    
    func templateImageWithCustomColor(customColor: CustomColors, type: TemplateType) -> ImageResource {
        let rawName = "\(customColor.rawValue)_TEMPLATE_\(type.rawValue)"
        let resource = ImageResource(name: rawName, bundle: .main)
        return resource
    }
    
    func saveTemplate(completion: @escaping (InvoiceEntity) -> Void) async {
        do {
            let bp = try await CoreDataManager.shared.fetchBusinessProfile()
            
            let client = chooseTemplateInvoiceModel.client
            
            let items = chooseTemplateInvoiceModel.itemOrServices.map {
                InvoiceItemRowModel(
                    name: $0.name ?? "",
                    pricePerUnit: $0.price ?? "",
                    quantity: $0.quantity ?? "1",
                    discountPercentage: $0.discount ?? "0",
                    taxPercentage: $0.tax ?? "0",
                    total: $0.total ?? ""
                )
            }
            
            let invoiceTemplateModel = InvoiceTemplateModel(
                id: chooseTemplateInvoiceModel.id,
                header: .init(
                    logo: bp?.image,
                    businessProfile: .init(
                        name: bp?.ownerName ?? "",
                        email: bp?.email ?? "",
                        phone: bp?.phoneNumber ?? "",
                        address: bp?.country ?? ""
                    ),
                    billTo: .init(
                        name: client.clientName ?? "",
                        email: client.email ?? "",
                        phone: client.phoneNumber ?? "",
                        address: client.country ?? ""
                    ),
                    invoiceInfo: .init(
                        number: chooseTemplateInvoiceModel.number,
                        date: chooseTemplateInvoiceModel.invoiceDate.formatedDateString,
                        dueDate: chooseTemplateInvoiceModel.dueDate.formatedDateString
                    )
                ),
                summary: .init(
                    currency: chooseTemplateInvoiceModel.currency,
                    subtotal: chooseTemplateInvoiceModel.subtotal,
                    discountPercentage: chooseTemplateInvoiceModel.discount,
                    taxPercentage: chooseTemplateInvoiceModel.tax,
                    total: chooseTemplateInvoiceModel.total
                ),
                items: items
            )
            
            do {
                let pdfURL = try await generateURL(
                    templateModel: invoiceTemplateModel,
                    oldURL: chooseTemplateInvoiceModel.pdfPath
                )
                
                let invoiceInput = InvoiceInput(
                    id: chooseTemplateInvoiceModel.id,
                    client: chooseTemplateInvoiceModel.client,
                    number: chooseTemplateInvoiceModel.number,
                    invoiceDate: chooseTemplateInvoiceModel.invoiceDate,
                    dueDate: chooseTemplateInvoiceModel.dueDate,
                    currency: chooseTemplateInvoiceModel.currency,
                    discount: chooseTemplateInvoiceModel.discount,
                    tax: chooseTemplateInvoiceModel.tax,
                    isPaid: false,
                    total: chooseTemplateInvoiceModel.total,
                    itemOrServices: chooseTemplateInvoiceModel.itemOrServices,
                    pdfFilePath: pdfURL,
                    type: templateType,
                    isInvoice: invoiceType == .invoice
                )
                
                
                let coreDataEntity = try await saveToDatabase(invoiceInput)
                
                await MainActor.run {
                    isFreeGeneratedInvoice = false
                    completion(coreDataEntity)
                }
            } catch {
                print(error, "error")
            }
        } catch {
            print(error, "error")
        }
    }
    
    private func setupSubscriptions() {
        cancellable = purchaseManager.isPremium
            .receive(on: RunLoop.main)
            .assign(to: \.isPremium, on: self)
    }
    
    private func saveToDatabase(_ invoiceInput: InvoiceInput) async throws -> InvoiceEntity {
        switch viewType {
        case .createInvoice, .createEstimate:
            return try await dataBaseService.createInvoice(with: invoiceInput)
        case .editInvoice, .editEstimate:
            return try await dataBaseService.update(invoice: invoiceInput)
        case .convertEstimateToInvoice:
            return try await dataBaseService.convertEstimateToInvoice(invoiceInput)
        }
    }
    
    private func generateURL(templateModel: InvoiceTemplateModel, oldURL: URL?) async throws -> URL {
        switch viewType {
        case .createInvoice, .createEstimate:
            let url = try PDFSaveService().generateAndSave(
                type: templateType,
                templateModel: templateModel,
                customColor: customColor.color,
                invoiceType: invoiceType
            )
            
            return url
        case .editInvoice, .editEstimate, .convertEstimateToInvoice:
            let url = try PDFSaveService().updateAndSave(
                oldURL: oldURL,
                type: templateType,
                templateModel: templateModel,
                customColor: customColor.color,
                invoiceType: invoiceType
            )
            return url
        }
    }
}
