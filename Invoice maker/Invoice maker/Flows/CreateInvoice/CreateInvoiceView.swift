import SwiftUI

struct CreateInvoiceView: View {
    @StateObject var viewModel: CreateInvoiceViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField {
        case invoiceNumber, currency
    }
    
    init(viewModel: CreateInvoiceViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            topView
            
            middleView
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $viewModel.sholdShowCurrencyPicker) {
            CurrencyPickerView(currency: $viewModel.currency)
                .presentationDetents([.large])
        }
        .datePickerPopup(
            isPresented: $viewModel.showInvoiceDatePicker,
            selectedDate: $viewModel.invoiceDate
        )
        .datePickerPopup(
            isPresented: $viewModel.showDueDatePicker,
            selectedDate: $viewModel.dueDate
        )
    }
    
    private var topView: some View {
        ZStack {
            HStack {
                Button {
                    coordinator.popToBack()
                } label: { }
                    .buttonStyle(.circle(.property1Arrow))
                
                Spacer()
            }
            
            Text(LocalizedStringKey(viewModel.getTopTitle()))
                .foregroundStyle(.black)
                .font(.sans(style: .semiBold, size: 20))
        }
        .padding(.bottom, 8)
    }
    
    
    private var middleView: some View {
        ScrollView {
            VStack(spacing: .zero) {
                Text("Invoice info")
                    .font(.sans(style: .semiBold, size: 26))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 12) {
                    CustomTextField(
                        focused: $focusedField,
                        equals: .invoiceNumber,
                        title: "Invoice number",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .numberPad,
                        text: $viewModel.invoiceNumber,
                        callError: .constant(false)
                    )
                    
                    HStack(spacing: 12) {
                        Button(viewModel.getInvoiceDate()) {
                            viewModel.tapOnInvoiceDateButton()
                        }
                        .buttonStyle(.disclosure(title: "Invoice date"))
                        
                        Button(viewModel.getDueDate()) {
                            viewModel.tapOnDueDateButton()
                        }
                        .buttonStyle(.disclosure(title: "Due date"))
                    }
                    
                    Button(viewModel.getCurrency()) {
                        viewModel.tapOnCurrencyButton()
                    }
                    .buttonStyle(.disclosure(title: "Currency"))
                }
                .padding(.top, 16)
                
                Text("Contact details")
                    .font(.sans(style: .semiBold, size: 26))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 32)
                
                VStack(spacing: 12) {
                    Button("Business profile") {
                        coordinator.pushTo(id: BusinessProfileView.navigationID) {
                            BusinessProfileView(viewModel: .init(stateView: .editing))
                        }
                    }
                    .buttonStyle(.disclosure(title: "From", isRequired: true))
                    
                    Button(viewModel.getClientName()) {
                        coordinator.pushTo(id: ClientsListView.navigationID) {
                            ClientsListView(
                                viewModel: .init(
                                    viewType: .choiseClient,
                                    selectedClient: viewModel.client
                                )
                            )
                        }
                    }
                    .buttonStyle(.disclosure(title: "Boll to", isRequired: true))
                }
                
                Text("Item info*") { string in
                    string.foregroundColor = .black
                    if let range = string.range(of: "*") {
                        string[range].foregroundColor = .violet4663FF
                    }
                }
                .font(.sans(style: .semiBold, size: 26))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 32)
                
                #warning("change currency for cell")
                VStack(spacing: 12) {
                    ForEach(viewModel.itemServices, id: \.self) { item in
                        Button("") { }
                        .buttonStyle(
                            .itemCell(
                                itemName: item.name ?? "",
                                discountType: DiscountType(rawValue: item.discountType ?? "") ?? .none,
                                discont: "\(item.discount ?? "")",
                                tax: "\(item.tax ?? "")",
                                total: item.price ?? "",
                                currency: .USD,
                                editAction: {
                                    coordinator.pushTo(id: EditItemServiceView.navigationID, destination: {
                                        EditItemServiceView(
                                            viewModel: .init(itemService: item)
                                        )
                                    })
                                },
                                deleteAction: {
                                    viewModel.deleteItemService(item)
                                }
                            )
                        )
                    }
                    
                    Button("Add item&service") {
                        
                    }
                    .buttonStyle(.add)
                }
                .padding(.top, 16)
            }
            .padding(.top, 24)
        }
        .scrollIndicators(.hidden)
    }
    
}

#Preview {
    CreateInvoiceView(viewModel: .init(viewType: .createInvoice))
}
