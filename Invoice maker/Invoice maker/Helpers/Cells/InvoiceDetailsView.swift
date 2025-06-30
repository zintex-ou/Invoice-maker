import SwiftUI

struct InvoiceDetailsView: View {
    let clientName: String
    let dueDate: Date
    let currency: Currency
    let total: String
    var id: Int

    @Binding var isPaid: Bool

    var isPressed: Bool = false
    var completion: ((Bool) -> Void)?

    private var isDueOrOverdue: Bool {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        let startOfDue = Calendar.current.startOfDay(for: dueDate)
        return startOfDue >= startOfToday
    }

    public init(
        clientName: String,
        dueDate: Date,
        currency: Currency,
        total: String,
        id: Int = 1,
        isPaid: Binding<Bool>,
        isPressed: Bool = false
    ) {
        self.clientName = clientName
        self.dueDate = dueDate
        self.currency = currency
        self.total = total
        self.id = id
        self._isPaid = isPaid
        self.isPressed = isPressed
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(clientName)
                    .font(.sans(style: .semiBold, size: 16))
                    .lineLimit(1)
                    .foregroundStyle(isPressed ? .black.opacity(0.5) : .black)

                HStack(spacing: 2) {
                    Image(isDueOrOverdue && !isPaid ? .expiredDueDateTimeIcon : .dueDateTimeIcon)
                        .resizable()
                        .frame(width: 12, height: 12)

                    Text("Due date: " + dueDate.formatedDateString)
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(isDueOrOverdue && !isPaid ? .orangeFF6F00 : .black767676)
                        .lineLimit(1)
                }
                .opacity(isPressed ? 0.5 : 1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(currency.rawValue + total)
                    .font(.sans(style: .semiBold, size: 16))
                    .lineLimit(1)
                    .foregroundStyle(.black)

                Menu {
                    Button {
                        completion?(true)
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
                        completion?(false)
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
}
