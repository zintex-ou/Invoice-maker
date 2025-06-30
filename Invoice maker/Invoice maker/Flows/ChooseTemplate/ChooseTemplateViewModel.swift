import SwiftUI

final class ChooseTemplateViewModel: ObservableObject {
    @Published var templateType: TemplateType = .topDark
    @Published var customColor: CustomColors = .blue
    @Published var templateIndex = 0
    @Published var shouldShowError: Bool = false
    @Published var isShowDeleteAlert: Bool = false

    var alert: AlertModel = .init(title: "", subtitle: "")
    let chooseTemplateInvoiceModel: ChooseTemplateInvoiceModel
    let invoiceType: InvoiceType
    
    private let dataBaseService = InvoiceDataBaseService.shared
    
    init(chooseTemplateInvoiceModel: ChooseTemplateInvoiceModel,
         invoiceType: InvoiceType
    ) {
        self.invoiceType = invoiceType
        self.chooseTemplateInvoiceModel = chooseTemplateInvoiceModel
    }
    
    func onCancelTapped() {
        isShowDeleteAlert = true
    }
    
    func title() -> String {
        invoiceType == .invoice ? "New invoice" : "New estimate"
    }
    
    func templateImageWithCustomColor(customColor: CustomColors, type: TemplateType) -> ImageResource {
        let rawName = "\(customColor.rawValue)_TEMPLATE_\(type.rawValue)"
        let resource = ImageResource(name: rawName, bundle: .main)
        return resource
    }
    
    @MainActor
    func saveTemplate(completion: @escaping (InvoiceEntity) -> Void) async {
        do {
            let uuid = UUID()
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
                id: uuid,
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
                let url = try PDFSaveService().generateAndSave(
                    type: templateType,
                    templateModel: invoiceTemplateModel,
                    customColor: customColor.color,
                    invoiceType: invoiceType
                )
                
                let invoiceInput = InvoiceInput(
                    id: uuid,
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
                    pdfFilePath: url,
                    type: templateType,
                    isInvoice: invoiceType == .invoice
                )
                
                let coreDataEntity = try await dataBaseService.createInvoice(with: invoiceInput)
                
                await MainActor.run {
                    completion(coreDataEntity)
                }
            } catch {
                print(error, "error")
            }
        } catch {
            print(error, "error")
        }
    }
}
