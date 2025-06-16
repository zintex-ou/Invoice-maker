import SwiftUI

struct DiscountPopover: View {
    @Binding var discountType: DiscountType
    @Binding var isPopoverShown: Bool

    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        if isPopoverShown {
            ZStack {
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isPopoverShown = false
                    }

                VStack(spacing: 0) {
                    Button("None") {
                        withAnimation {
                            discountType = .none
                            isPopoverShown = false
                        }

                        action()
                    }
                    .buttonStyle(.popoverButton(isChosen: discountType == .none))

                    Button("Percentage") {
                        withAnimation {
                            discountType = .percentage
                            isPopoverShown = false
                        }

                        action()
                    }
                    .buttonStyle(.popoverButton(isChosen: discountType == .percentage))

                    Button("Flat amount") {
                        withAnimation {
                            discountType = .flatAmount
                            isPopoverShown = false
                        }

                        action()
                    }
                    .buttonStyle(.popoverButton(isChosen: discountType == .flatAmount))
                }
                .frame(width: 176)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.13), radius: 6)
                }
                .overlay(
                    VStack(spacing: 44) {
                        Divider()

                        Divider()
                    }
                )
                .padding(.vertical, 12)
                .matchedGeometryEffect(
                    id: 1,
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

private struct DiscountPopoverPresenter: ViewModifier {
    @Binding var discountType: DiscountType
    @Binding var isPresented: Bool

    let namespace: Namespace.ID
    let action: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                DiscountPopover(
                    discountType: $discountType,
                    isPopoverShown: $isPresented,
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
    func showDiscountPopover(
        discountType: Binding<DiscountType>,
        isPresented: Binding<Bool>,
        namespace: Namespace.ID,
        action: @escaping () -> Void
    ) -> some View {
        modifier(
            DiscountPopoverPresenter(
                discountType: discountType,
                isPresented: isPresented,
                namespace: namespace,
                action: action
            )
        )
    }
}

private struct DiscountPopoverDemo: View {
    @Namespace var discoundPopover

    @State var isDiscountPopShow = false
    @State var discountType: DiscountType = .none

    var body: some View {
        ZStack {
            Button(discountType.rawValue) { isDiscountPopShow.toggle() }
                .buttonStyle(.discount(isPopoverShown: isDiscountPopShow, namespace: discoundPopover))
                .padding(16)
        }
        .showDiscountPopover(
            discountType: $discountType,
            isPresented: $isDiscountPopShow,
            namespace: discoundPopover
        ) {
            print("Action to update Discount type")
        }
    }
}

#Preview {
    DiscountPopoverDemo()
}
