import SwiftUI

struct InvoiceViewCell: View {
    let title: String
    let dueDate: Date
    let currency: Currency
    let totalPrice: Double
    let isInvoice: Bool
    @Binding var isPaid: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(.black)
                    .font(.sans(style: .semiBold, size: 16))
                
                HStack(spacing: 2) {
                    Image(.dueDateTimeIcon)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 12, height: 12)
                        .foregroundStyle(getColorForDate())
                    
                    Text("Due date: " + dueDate.formatedDateString)
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(getColorForDate())
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(currency.rawValue) \(String(format: "%.2f", totalPrice))")
                    .foregroundStyle(.black)
                    .font(.sans(style: .semiBold, size: 16))
                
                if isInvoice {
                    Menu {
                        Button {
                            tapOnMenuButton(false)
                        } label: {
                            HStack {
                                Text("Unpaid")
                                    .foregroundStyle(!isPaid ? .violet4663FF : .black)
                                    .font(.sans(style: .regular, size: 17))
                                
                                if !isPaid {
                                    Image(.property1Tick)
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        
                        Button {
                            tapOnMenuButton(true)
                        } label: {
                            HStack {
                                Text("Paid")
                                    .foregroundStyle(isPaid ? .violet4663FF : .black)
                                    .font(.sans(style: .regular, size: 17))
                                
                                if isPaid {
                                    Image(.property1Tick)
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width: 12, height: 12)
                                        .foregroundStyle(.violet4663FF)
                                }
                            }
                            
                        }
                    } label: {
                        HStack(spacing: 2) {
                            Text(isPaid ? "Paid" : "Unpaid")
                                .foregroundStyle(.black)
                                .font(.sans(style: .regular, size: 12))
                            
                            
                            Image(.discountArrow)
                                .resizable()
                                .frame(width: 12, height: 12)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isPaid ? .green69EB89 : .blueA0C4FF)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .lineLimit(1)
        .padding(.all, 16)
        .background(.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.default, value: isPaid)
    }
    
    func tapOnMenuButton(_ isPaid: Bool) {
        guard self.isPaid != isPaid else { return }
        self.isPaid = isPaid
    }
    
    func getColorForDate() -> Color {
        dueDate.isSameOrAfterDateIgnoringTime(.now) ? .black767676 : .orangeFF6F00
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(0..<5, id: \.self) { index in
            
            InvoiceViewCell(
                title: "Name of Client",
                dueDate: .now,
                currency: .USD,
                totalPrice: 100,
                isInvoice: true,
                isPaid: .constant(false))
        }
    }
    .padding(.horizontal, 16)
}
