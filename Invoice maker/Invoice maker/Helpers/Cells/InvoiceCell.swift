import SwiftUI

struct InvoiceCell: ButtonStyle {
    let clientName: String
    let dueDate: Date
    let id: Int
    let namespace: Namespace.ID

    @Binding var isPaid: Bool
    @Binding var isPopoverShown: Bool
    @Binding var selectedID: Int?

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(clientName)
                    .font(.sans(style: .semiBold, size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)

                HStack(spacing: 2) {
                    Image(.dueDateTimeIcon)
                        .resizable()
                        .frame(width: 12, height: 12)

                    Text("Due date: " + dueDateDateFormatter.string(from: dueDate))
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(configuration.isPressed ? .black767676.opacity(0.5) : .black767676)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }

            Spacer()

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
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
        .padding(.horizontal, 16)
        .background(.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 32))
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
        id: Int,
        namespace: Namespace.ID,
        isPaid: Binding<Bool>,
        isPopoverShown: Binding<Bool>,
        selectedID: Binding<Int?>

    ) -> InvoiceCell {
        InvoiceCell(
            clientName: clientName,
            dueDate: dueDate,
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
                    Button("Invoice #\(idx + 1)") {}
                        .buttonStyle(
                            .invoice(
                                clientName: "Name of client",
                                dueDate: .now,
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
                )
                .transition(
                    .opacity
                        .combined(with: .scale)
                        .animation(.bouncy(duration: 0.25, extraBounce: 0.2))
                )
            }
        }
        .onTapGesture {
            isPaidPopShow = false
        }
    }
}

struct InvoiceCellDemo_Previews: PreviewProvider {
    static var previews: some View {
        InvoiceCellDemo()
            .padding()
    }
}
