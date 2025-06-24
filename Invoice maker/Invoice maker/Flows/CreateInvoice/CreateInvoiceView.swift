import SwiftUI

struct BottomHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CreateInvoiceView: View {
    @StateObject var viewModel: CreateInvoiceViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @FocusState private var focusedField: FocusedField?
    @State var bottomHeight: CGFloat = .zero
    
    enum FocusedField {
        case invoiceNumber, currency, discount, tax
    }
    
    init(viewModel: CreateInvoiceViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: .zero) {
                topView
                
                middleView
            }
            
            bottomView
            
            let offset = viewModel.shouldShowErrorView
            ? -(max(0, bottomHeight) + 16)
            : 150
            
            ErrorView(text: "No items added. To create an invoice, please сlick the “Add item & service” button and fill in the item details.")
                .opacity(viewModel.shouldShowErrorView ? 1 : 0)
                .offset(y: offset)
                .animation(.linear(duration: 0.7), value: viewModel.shouldShowErrorView)
                .transition(.move(edge: .bottom))
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
                                    currency: Currency(from: item.currency),
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
                        coordinator.pushTo(id: ItemsServicesListView.navigationID) {
                            ItemsServicesListView(
                                viewModel: .init(
                                    viewType: .choiseItemsOrServices(viewModel.currency),
                                    selectedItemService: viewModel.itemServices
                                )
                            )
                        }
                    }
                    .buttonStyle(.add)
                }
                .padding(.top, 16)
            }
            .padding(.top, 24)
            
            Spacer()
                .frame(height: bottomHeight + 8)
        }
        .scrollIndicators(.hidden)
    }
    
    private var bottomView: some View {
        ZStack(alignment: .top) {
            RoundedCorners(radius: 25, corners: [.topLeft, .topRight])
                .foregroundStyle(.white)
                .frame(height: 92)
                .overlay(
                    RoundedCorners(radius: 25, corners: [.topLeft, .topRight])
                        .stroke(LinearGradient.tabBarStroke, lineWidth: 1)
                )
                .padding(.horizontal, -16)
            
            VStack(spacing: .zero) {
                Capsule()
                    .fill(.grayF5F5F5)
                    .frame(width: 36, height: 5)
                    .padding(.top, 6)
                    .onTapGesture {
                        viewModel.shouldShowDiscountAndTax()
                    }
                
                if viewModel.shouldShowDiscountTax {
                    VStack(spacing: .zero) {
                        HStack {
                            CustomTextField(
                                focused: $focusedField,
                                equals: .discount,
                                title: "Discount (%)",
                                placeholder: "",
                                isRequired: false,
                                keyboardType: .numberPad,
                                text: $viewModel.discount,
                                callError: .constant(false)
                            )
                            
                            CustomTextField(
                                focused: $focusedField,
                                equals: .tax,
                                title: "Tax (%)",
                                placeholder: "",
                                isRequired: false,
                                keyboardType: .numberPad,
                                text: $viewModel.tax,
                                callError: .constant(false)
                            )
                        }
                        .padding(.top, 13)
                        
                        HStack {
                            Text("Subtotal")
                            
                            Spacer()
                            
                            Text("\(viewModel.getCurrency()) 20 000,00")
                        }
                        .font(.sans(style: .regular, size: 16))
                        .foregroundStyle(.black)
                        .padding(.top, 16)
                        
                        Rectangle()
                            .fill(.black767676.opacity(0.3))
                            .frame(maxWidth: .infinity, maxHeight: 1)
                            .padding(.top, 8)
                    }
                    .transition(.move(edge: .bottom))
                }
                
                HStack {
                    Text("Total")
                    
                    Spacer()
                    
                    Text("\(viewModel.getCurrency()) 20 000,00")
                }
                .font(.sans(style: .semiBold, size: 20))
                .foregroundStyle(.black)
                .padding(.top, 16)
                
                Button("Create invoice") {
                    viewModel.tapOnCreateInvoiceButton()
                }
                .buttonStyle(.main)
                .padding(.top, 24)
                .padding(.bottom, 8)
            }
            .animation(.default, value: viewModel.shouldShowDiscountTax)
        }
        .background(.white)
        .overlay(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: BottomHeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(BottomHeightPreferenceKey.self) { value in
            bottomHeight = value
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

#Preview {
    CreateInvoiceView(viewModel: .init(viewType: .createInvoice))
}
