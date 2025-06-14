import SwiftUI

struct DatePickerPopup: View {
    @Binding var selectedDate: Date
    @State private var isVisible: Bool = false

    let onTap: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .opacity(isVisible ? 0.2 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            VStack(spacing: 20) {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(width: 297)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.04), radius: 4)
                )
                .scaleEffect(isVisible ? 1 : 0.6)
                .opacity(isVisible ? 1 : 0)
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

struct DatePickerPresenter: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                DatePickerPopup(selectedDate: $selectedDate) {
                    isPresented = false
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
    }
}

extension View {
    func datePickerPopup(
        isPresented: Binding<Bool>,
        selectedDate: Binding<Date>
    ) -> some View {
        modifier(
            DatePickerPresenter(
                isPresented: isPresented,
                selectedDate: selectedDate
            )
        )
    }
}

private struct DatePickerDemo: View {
    @State private var showInvoiceDatePicker = false
    @State private var showDueDatePicker = false
    @State private var invoiceDate: Date = .now
    @State private var dueDate: Date = .now

    var body: some View {
        HStack(spacing: 12) {
            Button(invoiceDate.formatedDateString) {
                showInvoiceDatePicker = true
            }
            .buttonStyle(.disclosure(title: "Invoice date"))

            Button(dueDate.formatedDateString) {
                showDueDatePicker = true
            }
            .buttonStyle(.disclosure(title: "Due date"))
        }
        .padding(16)
        .datePickerPopup(
            isPresented: $showInvoiceDatePicker,
            selectedDate: $invoiceDate
        )
        .datePickerPopup(
            isPresented: $showDueDatePicker,
            selectedDate: $dueDate
        )
    }
}

#Preview {
    DatePickerDemo()
}
