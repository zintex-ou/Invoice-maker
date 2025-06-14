import SwiftUI

struct DiscountPopover: View {
    @Binding var discountType: DiscountType
    @Binding var isPopoverShown: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        if isPopoverShown {
            ZStack {
                VStack(spacing: 0) {
                    Button("None") {
                        withAnimation {
                            discountType = .none
                            self.isPopoverShown = false
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

                    Button("Percentage") {
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

private struct DiscountPopoverDemo: View {
    @Namespace var discoundPopover

    @State var isDiscountPopShow = false
    @State var discountType: DiscountType = .none

    var body: some View {
        ZStack {
            Button(discountType.rawValue) { isDiscountPopShow.toggle() }
                .buttonStyle(.discount(isPopoverShown: isDiscountPopShow))
                .matchedGeometryEffect(id: 1, in: discoundPopover, anchor: .init(x: 1, y: 1))
                .padding(16)

            /// hide popover on Screen Tap (optional)
            if isDiscountPopShow {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isDiscountPopShow = false }
                    }
            }

            /// show popover
            DiscountPopover(
                discountType: $discountType,
                isPopoverShown: $isDiscountPopShow,
                namespace: discoundPopover
            ) {
                print("Action to update Discount type")
            }
        }
        .onTapGesture {
            /// hide popover on Screen Tap (optional)
            isDiscountPopShow = false
        }
    }
}

#Preview {
    DiscountPopoverDemo()
}
