import SwiftUI

struct AddNewItemServiceView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel: AddNewItemServiceViewModel
    
    @Namespace private var discountPopover
    @FocusState private var focusedField: FocusedItemServiceField?
    
    enum FocusedItemServiceField {
        case name, price, quantity, discount, tax
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.bottom, 24)
            
            itemServiceForm
            
            Button(viewModel.buttonTitle) {
                viewModel.onSaveTapped {
                    coordinator.popToBack()
                }
            }
            .buttonStyle(.main)
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $viewModel.sholdShowCurrencyPicker) {
            CurrencyPickerView(currency: $viewModel.currency)
                .presentationDetents([.large])
        }
        .alert(viewModel.deleteAlertTitle,
               isPresented: $viewModel.isShowDeleteAlert) {
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Delete", role: .destructive) {
                viewModel.deleteItemService()
                coordinator.popToBack()
            }
            
        } message: {
            Text(viewModel.deleteAlertMassage)
        }
        .alert("Save before leaving?",
               isPresented: $viewModel.showLeaveWithoutSavingAlert) {
            Button("Leave", role: .cancel) {
                coordinator.popToBack()
            }
            
            Button("Save", role: .destructive) {
                viewModel.onSaveTapped {
                    coordinator.popToBack()
                }
            }
            
        } message: {
            Text(viewModel.alertLeavewithoutSavingMessage)
        }
        .alert("Error",
               isPresented: $viewModel.showErrorAlert) {
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text(viewModel.errorAlertSubtitle)
        }
        .sheet(isPresented: $viewModel.sholdShowCurrencyPicker) {
            CurrencyPickerView(currency: $viewModel.currency)
                .presentationDetents([.large])
        }
    }
    
    var navigationBar: some View {
        ZStack {
            HStack {
                Button("") {
                    viewModel.onCloseTapped() {
                        coordinator.popToBack()
                    }
                }
                .buttonStyle(.circle(.property1Cross))
                
                Spacer()
                
                Text(viewModel.title)
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
                
                if case .editing = viewModel.viewState {
                    Button("") {
                        viewModel.showDeleteAlert()
                    }
                    .buttonStyle(.distructiveCircle(.property1Trash))
                }
            }
        }
    }
    
    @ViewBuilder
    private var itemServiceForm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.subtitle1)
                    .font(.sans(style: .semiBold, size: 26))
                    .foregroundStyle(.black)
                    .padding(.bottom, 4)
                
                CustomTextField(
                    focused: $focusedField,
                    equals: .name,
                    title: viewModel.nameFieldTitle,
                    placeholder: "",
                    isRequired: true,
                    keyboardType: .default,
                    text: $viewModel.name,
                    callError: $viewModel.nameError
                )
                
                Text(viewModel.subtitle2)
                    .font(.sans(style: .semiBold, size: 26))
                    .foregroundStyle(.black)
                    .padding(.bottom, 4)
                
                CustomTextField(
                    focused: $focusedField,
                    equals: .price,
                    title: "Price per unit (\($viewModel.currency.wrappedValue))",
                    placeholder: "",
                    isRequired: true,
                    keyboardType: .decimalPad,
                    text: $viewModel.price,
                    callError: $viewModel.priceError
                )
                
                Button(viewModel.currency.rawValue) {
                    viewModel.tapOnCurrencyButton()
                }
                .buttonStyle(.disclosure(title: "Currency"))
                
                CustomTextField(
                    focused: $focusedField,
                    equals: .quantity,
                    title: "Quantity of unit",
                    placeholder: "",
                    isRequired: false,
                    keyboardType: .decimalPad,
                    text: $viewModel.quantity,
                    callError: .constant(false)
                )
                
                ZStack {
                    Button(viewModel.discountType.rawValue) {
                        viewModel.isDiscountPopShow.toggle()
                    }
                    .buttonStyle(.discount(isPopoverShown: viewModel.isDiscountPopShow, namespace: discountPopover))
                }
                .zIndex(100)
                .overlay(alignment: .topTrailing) {
                    if viewModel.isDiscountPopShow {
                        DiscountPopover(
                            discountType: $viewModel.discountType,
                            isPopoverShown: $viewModel.isDiscountPopShow,
                            namespace: discountPopover,
                            action: { }
                        )
                    }
                }
                
                if viewModel.discountType != .none {
                    CustomTextField(
                        focused: $focusedField,
                        equals: .discount,
                        title: "Discount \(viewModel.discountType == .percentage ? "(%)" : "(\(viewModel.currency.rawValue))")",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .decimalPad,
                        text: $viewModel.discount,
                        callError: .constant(false)
                    )
                }
                
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
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
