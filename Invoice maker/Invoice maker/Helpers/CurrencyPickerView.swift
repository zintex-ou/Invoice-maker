import SwiftUI

struct CurrencyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var currency: Currency
    private let items = Currency.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Currency")
                    .font(.sans(style: .semiBold, size: 20))
                    .padding(.bottom, 12)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(.property1Cross)
                        .renderingMode(.template)
                        .foregroundStyle(.black)
                }

            }
            
            ScrollView {
                ForEach(items, id: \.self) { option in
                    RadioButton(
                        label: option.rawValue,
                        isSelected: option == currency
                    ) {
                        currency = option
                    }
                    .padding(15)
                    .background {
                        Capsule()
                            .fill(.grayF5F5F5)
                    }
                }
            }
            
            Spacer()
        }
        .onChange(of: currency) { _ in
            dismiss()
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .presentationDragIndicator(.visible)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

#Preview {
    CurrencyPickerView(currency: .constant(.USD))
}
