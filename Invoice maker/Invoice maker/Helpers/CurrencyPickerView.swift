import SwiftUI

struct CurrencyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var currency: Currency
    private let items = Currency.allCases
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            currencyList
        }
        .onChange(of: currency) { _ in
            dismiss()
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .presentationDragIndicator(.visible)
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private var header: some View {
        HStack(spacing: 0) {
            Text("Currency")
                .font(.sans(style: .semiBold, size: 20))
                .padding(.bottom, 12)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(.property1Cross)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.black)
                    .frame(width: 24, height: 24)
            }
            .frame(width: 40, height: 40)
        }
        .frame(height: 40)
    }
    
    private var currencyList: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(items, id: \.self) { option in
                        Button(option.rawValue) { currency = option }
                            .buttonStyle(.radioButton(isSelected: option == currency))
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 50)
            }
            .scrollIndicators(.hidden)
            
            ListTopShadow()
        }
    }
}

#Preview {
    CurrencyPickerView(currency: .constant(.USD))
}
