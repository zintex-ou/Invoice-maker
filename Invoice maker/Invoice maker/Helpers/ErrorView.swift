import SwiftUI

struct ErrorView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Image(.property1Attention)
                .renderingMode(.template)
                .foregroundStyle(.redDF0101)
            
            Text(text)
                .foregroundStyle(.redDF0101)
                .font(.sans(style: .regular, size: 16))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.98, green: 0.84, blue: 0.84))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    ErrorView(text: "No items added. To create an invoice, please сlick the “Add item & service” button and fill in the item details.")
}
