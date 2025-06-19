import SwiftUI

struct AddItemServiceView: View {
    @Namespace var discoundPopover
    @Binding var nameError: Bool
    @Binding var priceError: Bool
    @Binding var itemService: ItemServiceInput
    
    @State var isDiscountPopShow = false
    
    @FocusState private var focusedField: FocusedItemServiceField?
    
    enum FocusedItemServiceField {
        case name, price, quantity, discount, tax
    }
    
    var name: String
    var currency: Currency
    var title: String
    var subtitle: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.sans(style: .semiBold, size: 26))
                    .foregroundStyle(.black)
                    .padding(.bottom, 4)
                
                CustomTextField(
                    focused: $focusedField,
                    equals: .name,
                    title: name,
                    placeholder: "",
                    isRequired: true,
                    keyboardType: .default,
                    text: $itemService.name,
                    callError: $nameError
                )
                
                Text(subtitle)
                    .font(.sans(style: .semiBold, size: 26))
                    .foregroundStyle(.black)
                    .padding(.bottom, 4)
                
                CustomTextField(
                    focused: $focusedField,
                    equals: .price,
                    title: "Price per unit (\(currency.rawValue))",
                    placeholder: "",
                    isRequired: true,
                    keyboardType: .decimalPad,
                    text: $itemService.price,
                    callError: $priceError
                )
                
                CustomTextField(
                    focused: $focusedField,
                    equals: .quantity,
                    title: "Quantity of unit",
                    placeholder: "",
                    isRequired: false,
                    keyboardType: .decimalPad,
                    text: $itemService.quantity,
                    callError: .constant(false)
                )
                
                ZStack {
                    Button(itemService.discountType.rawValue) { isDiscountPopShow.toggle() }
                        .buttonStyle(.discount(isPopoverShown: isDiscountPopShow, namespace: discoundPopover))
                }
                .zIndex(100)
                .overlay(alignment: .topTrailing) {
                    if isDiscountPopShow {
                        DiscountPopover(
                            discountType: $itemService.discountType,
                            isPopoverShown: $isDiscountPopShow,
                            namespace: discoundPopover,
                            action: {
                                
                            }
                        )
                    }
                }
                
                if itemService.discountType != .none {
                    CustomTextField(
                        focused: $focusedField,
                        equals: .discount,
                        title: "Discount \(itemService.discountType == .percentage ? "(%)" : "(\(currency.rawValue))")",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .decimalPad,
                        text: $itemService.discount,
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
                    text: $itemService.tax,
                    callError: .constant(false)
                )
                
                Spacer()
            }
        }
    }
}
