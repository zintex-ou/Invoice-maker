import SwiftUI

struct PaidPopover: View {
    @Binding var isPaid: Bool
    @Binding var isPopoverShown: Bool
    @Binding var selectedID: Int?
    let namespace: Namespace.ID

    var body: some View {
        if isPopoverShown {
            ZStack {
                VStack(spacing: 0) {
                    Button("Unpaid") {
                        withAnimation {
                            isPaid = false
                            self.isPopoverShown = false
                        }
                    }
                    .buttonStyle(.popupButton(isChosen: !isPaid))

                    Button("Paid") {
                        withAnimation {
                            isPaid = true
                            isPopoverShown = false
                        }
                    }
                    .buttonStyle(.popupButton(isChosen: isPaid))
                }
                .frame(width: 176)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.13), radius: 6)
                }
                .overlay(Divider())
                .padding(.vertical, 12)
                .matchedGeometryEffect(
                    id: selectedID ?? -1,
                    in: namespace,
                    properties: .position,
                    anchor: .topTrailing,
                    isSource: false
                )
            }
        }
    }
}

#Preview {
    PopoverDemo()
}

struct TestInvoiceModel {
    var isPaid: Bool
}

struct PopoverDemo: View {
    @Namespace var paidPopover

    @State var isPaidPopShow = false
    @State var popoverID: Int? = nil
    @State var invoicesArray = Array(repeating: TestInvoiceModel(isPaid: false), count: 5)

    var body: some View {
        ZStack {
            VStack {
                Spacer()

                /// some Invoice List
                ForEach(invoicesArray.indices, id: \.self) { id in
                    Button(invoicesArray[id].isPaid ? "Paid" : "Unpaid") {
                        popoverID = id
                        isPaidPopShow.toggle()
                    }
                    .buttonStyle(.paid(isPaid: $invoicesArray[id].isPaid, isPopoverShown: isPaidPopShow && popoverID == id))
                    .matchedGeometryEffect(id: id, in: paidPopover, anchor: .init(x: 1, y: 1))
                }

                Spacer()
            }

            /// hide popover on Screen Tap (optional)
            if isPaidPopShow {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isPaidPopShow = false }
                    }
            }

            /// show popover
            if let selectedID = popoverID {
                PaidPopover(isPaid: $invoicesArray[selectedID].isPaid, isPopoverShown: $isPaidPopShow, selectedID: $popoverID, namespace: paidPopover)
                    .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
            }
        }
        .onTapGesture {
            /// hide popover on Screen Tap (optional)
            isPaidPopShow = false
        }
    }
}
