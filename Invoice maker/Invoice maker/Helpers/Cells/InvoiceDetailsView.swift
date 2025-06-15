import SwiftUI

struct InvoiceDetailsView: View {
    let clientName: String
    let dueDate: Date
    let currency: Currency
    let total: String
    var id: Int
    let namespace: Namespace.ID

    @Binding var isPaid: Bool
    @Binding var isPopoverShown: Bool
    @Binding var selectedID: Int?

    var isPressed: Bool = false

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
        namespace: Namespace.ID,
        isPaid: Binding<Bool>,
        isPopoverShown: Binding<Bool>,
        selectedID: Binding<Int?> = .constant(1),
        isPressed: Bool = false
    ) {
        self.clientName = clientName
        self.dueDate = dueDate
        self.currency = currency
        self.total = total
        self.id = id
        self.namespace = namespace
        self._isPaid = isPaid
        self._isPopoverShown = isPopoverShown
        self._selectedID = selectedID
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

                Button(action: {
                    withAnimation {
                        selectedID = id
                        isPopoverShown.toggle()
                    }
                }) {
                    Text(isPaid ? "Paid" : "Unpaid")
                }
                .buttonStyle(
                    .paid(isPaid: $isPaid, isPopoverShown: isPopoverShown && selectedID == id, namespace: namespace, id: id)
                )
            }
        }
    }
}

private struct InvoiceDetailsViewDemo: View {
    @Namespace private var paidPopover
    @State private var isPaidPopShow = false
    @State private var isPaid = false

    var body: some View {
        ZStack {
            InvoiceDetailsView(
                clientName: "John Smith",
                dueDate: .distantPast,
                currency: .USD,
                total: "19,570.00",
                namespace: paidPopover,
                isPaid: $isPaid,
                isPopoverShown: $isPaidPopShow
            )
        }
        .padding(.horizontal, 16)
        .paidPopover(
            isPaid: $isPaid,
            isPresented: $isPaidPopShow,
            namespace: paidPopover
        ) {
            print("Action to update CoreData isPaid State")
        }
    }
}

#Preview {
    InvoiceDetailsViewDemo()
}
