import SwiftUI

struct AddItemServiceView: View {
    @Namespace var discoundPopover
    @Binding var nameError: Bool
    @Binding var priceError: Bool
    @Binding var itemService: ItemServiceInput
    
    @State var isDiscountPopShow = false
    
    var name: String
    var currency: Currency
    
    var body: some View {
        ScrollView {
            VStack {
                CustomTextField(
                    title: name,
                    placeholder: "",
                    isRequired: true,
                    keyboardType: .default,
                    text: $itemService.name,
                    callError: $nameError
                )
                
                CustomTextField(
                    title: "Price per unit (\(currency.rawValue))",
                    placeholder: "",
                    isRequired: true,
                    keyboardType: .decimalPad,
                    text: $itemService.price,
                    callError: $priceError
                )
                
                CustomTextField(
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
                        title: "Discount \(itemService.discountType == .percentage ? "(%)" : "(\(currency.rawValue))")",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .decimalPad,
                        text: $itemService.discount,
                        callError: .constant(false)
                    )
                }
                
                CustomTextField(
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
