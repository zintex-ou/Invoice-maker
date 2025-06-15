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
        InvoiceDetailsView(
            clientName: clientName,
            dueDate: dueDate,
            currency: currency,
            total: total,
            id: id,
            namespace: namespace,
            isPaid: $isPaid,
            isPopoverShown: $isPopoverShown,
            selectedID: $selectedID,
            isPressed: configuration.isPressed
        )
        .frame(maxWidth: .infinity, minHeight: 85, maxHeight: 85)
        .padding(.horizontal, 16)
        .background(.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
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

private struct InvoiceCellDemo: View {
    @Namespace private var paidPopover

    @State private var isPaidPopShow = false
    @State private var popoverID: Int? = nil
    @State private var invoicesArray = Array(
        repeating: TestInvoiceModel(isPaid: false),
        count: 5
    )

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(invoicesArray.indices, id: \.self) { idx in
                        Button("") { print("tapOnInvoiceCell") }
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
                }
                .padding(.top, 24)
                .padding(.bottom, 72)
            }
            .scrollIndicators(.hidden)

            ListTopShadow()
        }
        .padding(16)
        .paidPopover(
            isPaid: $invoicesArray[popoverID ?? 0].isPaid,
            isPresented: $isPaidPopShow,
            selectedID: $popoverID,
            namespace: paidPopover
        ) {
            print("Action to update CoreData isPaid State")
        }
    }
}

#Preview {
    InvoiceCellDemo()
}
