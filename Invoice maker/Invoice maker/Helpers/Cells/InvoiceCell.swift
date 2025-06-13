import SwiftUI

struct InvoiceCell: ButtonStyle {
    let clientName: String
    let dueDate: Date
    let currency: Currency
    let total: String
    let id: Int
    let namespace: Namespace.ID

    @Binding var isPaid: Bool
    @Binding var isPopoverShown: Bool
    @Binding var selectedID: Int?

    func makeBody(configuration: Configuration) -> some View {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        let startOfDue = Calendar.current.startOfDay(for: dueDate)
        let isDueOrOverdue = startOfDue >= startOfToday

        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(clientName)
                    .font(.sans(style: .semiBold, size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)

                HStack(spacing: 2) {
                    Image(isDueOrOverdue && !isPaid ? .expiredDueDateTimeIcon : .dueDateTimeIcon)
                        .resizable()
                        .frame(width: 12, height: 12)

                    Text("Due date: " + dueDateDateFormatter.string(from: dueDate))
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(isDueOrOverdue && !isPaid ? .orangeFF6F00 : .black767676)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .opacity(configuration.isPressed ? 0.5 : 1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(currency.rawValue + total)
                    .font(.sans(style: .semiBold, size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(.black)

                Button(action: {
                    withAnimation {
                        selectedID = id
                        isPopoverShown.toggle()
                    }
                }) {
                    Text(isPaid ? "Paid" : "Unpaid")
                }
                .buttonStyle(.paid(isPaid: $isPaid,
                                   isPopoverShown: isPopoverShown && selectedID == id))
                .matchedGeometryEffect(
                    id: id,
                    in: namespace,
                    anchor: .init(x: 1, y: 1)
                )
            }
        }
        .frame(maxWidth: .infinity, minHeight: 85, maxHeight: 85)
        .padding(.horizontal, 16)
        .background(.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }

    private let dueDateDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d MMM, yyyy"
        return df
    }()
}

extension ButtonStyle where Self == InvoiceCell {
    static func invoice(
        clientName: String,
        dueDate: Date,
        currency: Currency,
        total: String,
        id: Int,
        namespace: Namespace.ID,
        isPaid: Binding<Bool>,
        isPopoverShown: Binding<Bool>,
        selectedID: Binding<Int?>

    ) -> InvoiceCell {
        InvoiceCell(
            clientName: clientName,
            dueDate: dueDate,
            currency: currency,
            total: total,
            id: id,
            namespace: namespace,
            isPaid: isPaid,
            isPopoverShown: isPopoverShown,
            selectedID: selectedID
        )
    }
}

struct InvoiceCellDemo: View {
    @Namespace private var paidPopover

    @State private var isPaidPopShow = false
    @State private var popoverID: Int? = nil
    @State private var invoicesArray = Array(
        repeating: TestInvoiceModel(isPaid: false),
        count: 5
    )

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                ForEach(invoicesArray.indices, id: \.self) { idx in
                    Button("Invoice #\(idx + 1)") { print("tapOnInvoiceCell") }
                        .buttonStyle(
                            .invoice(
                                clientName: "Name of client",
                                dueDate: Calendar.current.startOfDay(for: .distantFuture),
                                currency: .USD,
                                total: "20,00",
                                id: idx,
                                namespace: paidPopover,
                                isPaid: $invoicesArray[idx].isPaid,
                                isPopoverShown: $isPaidPopShow,
                                selectedID: $popoverID
                            )
                        )
                }
                Spacer()
            }

            if isPaidPopShow {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isPaidPopShow = false }
                    }
            }

            if let selectedID = popoverID {
                PaidPopover(
                    isPaid: $invoicesArray[selectedID].isPaid,
                    isPopoverShown: $isPaidPopShow,
                    selectedID: $popoverID,
                    namespace: paidPopover
                ) {
                    print("Action to update CoreData isPaid State")
                }
                .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
            }
        }
        .padding(16)
        .onTapGesture {
            isPaidPopShow = false
        }
    }
}

#Preview {
    InvoiceCellDemo()
}
