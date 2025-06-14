import Lottie
import SwiftUI

struct PopupView: View {
    let message: String
    let lottie: String
    let onTap: () -> Void

    @State private var isVisible: Bool = false

    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismiss()
                }

            VStack(spacing: 8) {
                LottieView(animation: .named(lottie))
                    .playbackMode(
                        .playing(
                            .fromProgress(
                                0,
                                toProgress: 1.0,
                                loopMode: .playOnce
                            )
                        )
                    )
                    .animationDidFinish { finished in
                        if finished {
                            dismiss()
                        }
                    }
                    .resizable()
                    .frame(width: 70, height: 70)

                Text(message)
                    .font(.sans(style: .regular, size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: 113)
            }
            .padding(.vertical, 26.5)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(.ultraThickMaterial)
                    .shadow(color: .black.opacity(0.12), radius: 4)
            )
            .scaleEffect(isVisible ? 1 : 0.6)
            .opacity(isVisible ? 1 : 0)
            .onTapGesture {
                dismiss()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                isVisible = true
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onTap()
        }
    }
}

struct PopupPresenter: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let lottie: String

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                PopupView(message: message, lottie: lottie) {
                    isPresented = false
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
    }
}

extension View {
    func showPopup(
        isPresented: Binding<Bool>,
        message: String,
        lottie: String
    ) -> some View {
        modifier(PopupPresenter(
            isPresented: isPresented,
            message: message,
            lottie: lottie
        ))
    }
}

private struct DemoPopupView: View {
    @State private var showDonePopup = false
    @State private var showSentPopup = false

    var body: some View {
        VStack(spacing: 16) {
            Button("Payment Confirmed") {
                showDonePopup = true
            }
            .buttonStyle(.main)

            Button("Invoice Sent") {
                showSentPopup = true
            }
            .buttonStyle(.main)
        }
        .padding(16)
        .showPopup(
            isPresented: $showDonePopup,
            message: "Payment confirmed!",
            lottie: "DoneLottie"
        )
        .showPopup(
            isPresented: $showSentPopup,
            message: "Invoice is send!",
            lottie: "PlaneLottie"
        )
    }
}

#Preview {
    DemoPopupView()
}
