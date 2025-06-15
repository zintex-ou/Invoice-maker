import SwiftUI

struct PaidPopover: View {
    @Binding var isPaid: Bool
    @Binding var isPopoverShown: Bool
    @Binding var selectedID: Int?

    let namespace: Namespace.ID
    let action: () -> Void

    /// Use this init() when there will be more than one `PaidPopover` on the same screen
    public init(
        isPaid: Binding<Bool>,
        isPopoverShown: Binding<Bool>,
        selectedID: Binding<Int?>,
        namespace: Namespace.ID,
        action: @escaping () -> Void
    ) {
        self._isPaid = isPaid
        self._isPopoverShown = isPopoverShown
        self._selectedID = selectedID
        self.namespace = namespace
        self.action = action
    }

    /// Use this init() when there will be only one `PaidPopover` on one screen
    public init(
        isPaid: Binding<Bool>,
        isPopoverShown: Binding<Bool>,
        namespace: Namespace.ID,
        action: @escaping () -> Void
    ) {
        self.init(
            isPaid: isPaid,
            isPopoverShown: isPopoverShown,
            selectedID: .constant(1),
            namespace: namespace,
            action: action
        )
    }

    var body: some View {
        if isPopoverShown {
            ZStack {
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isPaid = false
                        isPopoverShown = false
                    }

                VStack(spacing: 0) {
                    Button("Unpaid") {
                        withAnimation {
                            isPaid = false
                            isPopoverShown = false
                        }

                        action()
                    }
                    .buttonStyle(.popoverButton(isChosen: !isPaid))

                    Button("Paid") {
                        withAnimation {
                            isPaid = true
                            isPopoverShown = false
                        }

                        action()
                    }
                    .buttonStyle(.popoverButton(isChosen: isPaid))
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
            .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
        }
    }
}

struct PaidPopoverPresenter: ViewModifier {
    @Binding var isPaid: Bool
    @Binding var isPresented: Bool
    @Binding var selectedID: Int?
    let namespace: Namespace.ID
    let action: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented, selectedID != nil {
                PaidPopover(
                    isPaid: $isPaid,
                    isPopoverShown: $isPresented,
                    selectedID: $selectedID,
                    namespace: namespace,
                    action: action
                )
                .transition(.opacity.combined(with: .scale))
                .zIndex(1)
            }
        }
    }
}

extension View {
    /// Use this init() when there will be more than one `PaidPopover` on the same screen
    func paidPopover(
        isPaid: Binding<Bool>,
        isPresented: Binding<Bool>,
        selectedID: Binding<Int?>,
        namespace: Namespace.ID,
        action: @escaping () -> Void
    ) -> some View {
        modifier(
            PaidPopoverPresenter(
                isPaid: isPaid,
                isPresented: isPresented,
                selectedID: selectedID,
                namespace: namespace,
                action: action
            )
        )
    }

    /// Use this init() when there will be only one `PaidPopover` on one screen
    func paidPopover(
        isPaid: Binding<Bool>,
        isPresented: Binding<Bool>,
        namespace: Namespace.ID,
        action: @escaping () -> Void
    ) -> some View {
        paidPopover(
            isPaid: isPaid,
            isPresented: isPresented,
            selectedID: .constant(1),
            namespace: namespace,
            action: action
        )
    }
}

struct TestInvoiceModel {
    var isPaid: Bool
}

private struct PaidPopoverDemo: View {
    @Namespace var paidPopover

    @State var isPaidPopShow = false
    @State var popoverID: Int? = nil
    @State var invoicesArray = Array(repeating: TestInvoiceModel(isPaid: false), count: 5)

    var body: some View {
        VStack {
            ForEach(invoicesArray.indices, id: \.self) { id in
                Button(invoicesArray[id].isPaid ? "Paid" : "Unpaid") {
                    popoverID = id
                    isPaidPopShow.toggle()
                }
                .buttonStyle(.paid(isPaid: $invoicesArray[id].isPaid, isPopoverShown: isPaidPopShow && popoverID == id))
                .matchedGeometryEffect(id: id, in: paidPopover, anchor: .init(x: 1, y: 1))
            }
        }
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
    PaidPopoverDemo()
}
