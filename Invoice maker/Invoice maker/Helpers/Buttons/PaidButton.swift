import SwiftUI

struct ContentView: View {
    @Namespace var nsPopover

    @State var isPaid = false
    @State var isPopoverShown = false
    @State var selectedID: Int? = nil

    var body: some View {
        ZStack {
            VStack {
                Spacer()

                ForEach(1 ... 3, id: \.self) { id in
                    Button(isPaid ? "Paid" : "Unpaid") {
                        selectedID = id
                        isPopoverShown.toggle()
                    }
                    .buttonStyle(.paid(isPaid: $isPaid, isPopoverShown: isPopoverShown && selectedID == id))
                    .matchedGeometryEffect(id: id, in: nsPopover, anchor: .init(x: 1, y: 1))
                }

                Spacer()
            }

            CustomPopover(isPaid: $isPaid, isPopoverShown: $isPopoverShown, selectedID: $selectedID, namespace: nsPopover)
                .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
        }
        .onTapGesture {
            isPopoverShown = false
        }
    }
}

struct CustomPopover: View {
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

struct PaidButton: ButtonStyle {
    @Binding var isPaid: Bool
    var isPopoverShown: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 2) {
            configuration.label
                .font(.sans(style: .regular, size: 12))
                .foregroundColor(.black)
                .minimumScaleFactor(0.8)
                .transition(.scale)

            Image(.menuOffIcon)
                .resizable()
                .renderingMode(.template)
                .frame(width: 12, height: 12)
                .foregroundStyle(.black)
                .rotation3DEffect(
                    .degrees(isPopoverShown ? 180 : 0),
                    axis: (x: 1, y: 0, z: 0)
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .foregroundStyle(isPaid ? .greenB4F5C4 : .blueDAE0FF)
                .transition(.scale)
        )
    }
}

extension ButtonStyle where Self == PaidButton {
    static func paid(isPaid: Binding<Bool>, isPopoverShown: Bool) -> Self {
        PaidButton(isPaid: isPaid, isPopoverShown: isPopoverShown)
    }
}

struct PopupButtonStyle: ButtonStyle {
    var isChosen: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            configuration.label
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(isChosen ? .violet4663FF : .black)

            Spacer()

            if isChosen {
                Image(.checkMarkIcon)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == PopupButtonStyle {
    static func popupButton(isChosen: Bool) -> Self {
        PopupButtonStyle(isChosen: isChosen)
    }
}

#Preview {
    ContentView()
}

// struct ContentView: View {
//    @State private var isPopoverShown = false
//    @State var isPaid = false
//    @Namespace private var nsPopover
//
//    var body: some View {
//        ZStack {
//            Button(isPaid ? "Paid" : "Unpaid") { isPopoverShown.toggle() }
//                .buttonStyle(.paid(isPaid: $isPaid, isPopoverShown: isPopoverShown))
//                .matchedGeometryEffect(id: 1, in: nsPopover, anchor: .init(x: 1, y: 1))
//
////            customPopover
////                .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
//
//            CustomPopover(isPaid: $isPaid, isPopoverShown: $isPopoverShown, namespace: nsPopover)
//                .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
//        }
//        .onTapGesture {
//            isPopoverShown = false
//        }
//    }
//
//    @ViewBuilder
//    private var customPopover: some View {
//        if isPopoverShown {
//            ZStack {
//                VStack(spacing: 0) {
//                    Button("Unpaid") {
//                        withAnimation {
//                            isPaid = false
//                            isPopoverShown = false
//                        }
//                    }
//                    .buttonStyle(.popupButton(isChosen: !isPaid))
//
//                    Button("Paid") {
//                        withAnimation {
//                            isPaid = true
//                            isPopoverShown = false
//                        }
//                    }
//                    .buttonStyle(.popupButton(isChosen: isPaid))
//                }
//                .frame(width: 176)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .background {
//                    RoundedRectangle(cornerRadius: 12)
//                        .foregroundStyle(.ultraThinMaterial)
//                        .shadow(color: .black.opacity(0.13), radius: 6)
//                }
//                .overlay(Divider())
//                .padding(.vertical, 12)
//                .matchedGeometryEffect(
//                    id: 1,
//                    in: nsPopover,
//                    properties: .position,
//                    anchor: .topTrailing,
//                    isSource: false
//                )
//            }
//        }
//    }
// }
