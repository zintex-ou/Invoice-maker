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
    
    enum FocusedField {
        case invoiceNumber, currency, discount, tax
    }
    
    var gesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                let location = value.location
                if location.y < 0 {
                    viewModel.isPresenterDiskont = true
                } else {
                    viewModel.isPresenterDiskont = false
                }
            }
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
            ? -(max(0, viewModel.bottomHeight) + 16)
            : 150
            
            ErrorView(text: viewModel.errorText)
                .opacity(viewModel.shouldShowErrorView ? 1 : 0)
                .offset(y: viewModel.shouldShowErrorView ? offset : 200)
                .animation(.easeOut(duration: 0.7), value: viewModel.shouldShowErrorView)
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
        .animation(.easeInOut, value: viewModel.isPresenterDiskont)
        .animation(.default, value: viewModel.bottomHeight)
        .animation(.default, value: viewModel.itemServices.count)
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
                Text(viewModel.getInfoTitle())
                    .font(.sans(style: .semiBold, size: 26))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 12) {
                    CustomTextField(
                        focused: $focusedField,
                        equals: .invoiceNumber,
                        title: viewModel.getNumberTitle(),
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
                        .buttonStyle(.disclosure(title: viewModel.getDateTitle()))
                        
                        
                        if viewModel.viewType == .createInvoice ||
                            viewModel.viewType == .editInvoice {
                            Button(viewModel.getDueDate()) {
                                viewModel.tapOnDueDateButton()
                            }
                            .buttonStyle(.disclosure(title: "Due date"))
                        }
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
                                        coordinator.pushTo(
                                            id: AddNewItemServiceView.navigationID,
                                            destination: {
                                                AddNewItemServiceView(
                                                    viewModel: .init(
                                                        offerType: item.isItem ? .items : .services,
                                                        viewState: .editing(entity: item)
                                                    )
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
                .frame(height: viewModel.bottomHeight + 8)
        }
        .scrollIndicators(.hidden)
    }
    
    private var bottomView: some View {
        VStack(spacing: .zero) {
            RoundedCorners(radius: 25, corners: [.topLeft, .topRight])
                .foregroundStyle(.white)
                .frame(height: 24)
                .overlay(
                    RoundedCorners(radius: 25, corners: [.topLeft, .topRight])
                        .stroke(LinearGradient.tabBarStroke, lineWidth: 1)
                )
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(.grayF5F5F5)
                        .frame(width: 36, height: 5)
                        .padding(.top, 6)
                }
                .padding(.horizontal, -16)
                .gesture(gesture)
            
            if viewModel.isPresenterDiskont {
                VStack(spacing: .zero) {
                    HStack {
                        CustomTextField(
                            focused: $focusedField,
                            equals: .discount,
                            title: "Discount (%)",
                            placeholder: "",
                            isRequired: false,
                            keyboardType: .decimalPad,
                            text: $viewModel.discount,
                            callError: .constant(false)
                        )
                        
                        CustomTextField(
                            focused: $focusedField,
                            equals: .tax,
                            title: "Tax (%)",
                            placeholder: "",
                            isRequired: false,
                            keyboardType: .decimalPad,
                            text: $viewModel.tax,
                            callError: .constant(false)
                        )
                    }
                    
                    HStack {
                        Text("Subtotal")
                        
                        Spacer()
                        
                        Text("\(viewModel.getCurrency()) \(String(format: "%.2f", viewModel.getSubTotalPrice()))")
                    }
                    .font(.sans(style: .regular, size: 16))
                    .foregroundStyle(.black)
                    .padding(.top, 16)
                    
                    Rectangle()
                        .fill(.black767676.opacity(0.3))
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .padding(.top, 8)
                }
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            VStack(spacing: 24) {
                HStack {
                    Text("Total")
                    
                    Spacer()
                    
                    Text("\(viewModel.getCurrency()) \(String(format: "%.2f", viewModel.getTotalPrice()))")
                }
                .font(.sans(style: .semiBold, size: 20))
                .foregroundStyle(.black)
                
                Button(viewModel.getButtonTitle()) {
                    viewModel.tapOnCreateInvoiceButton(
                        completion: { viewType in
                            let type = (viewType == .createEstimate || viewType == .editEstimate) ? InvoiceType.estimate : InvoiceType.invoice
                            if let chooseTemplateInvoiceModel = viewModel.createChooseTemplateInvoiceModel() {
                                coordinator.pushTo(id: ChooseTemplateView.navigationID) {
                                    ChooseTemplateView(
                                        viewModel: .init(
                                            chooseTemplateInvoiceModel: chooseTemplateInvoiceModel,
                                            invoiceType: type
                                        )
                                    )
                                }
                            }
                        })
                }
                .buttonStyle(.main)
                .padding(.bottom, 8)
            }
            .background(.white)
        }
        .background(.white)
        .overlay(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: BottomHeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(BottomHeightPreferenceKey.self) { value in
            viewModel.bottomHeight = value
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

#Preview {
    CreateInvoiceView(viewModel: .init(viewType: .createInvoice))
}
