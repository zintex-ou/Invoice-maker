import SwiftUI

struct DatePickerView: View {
    @Binding private var selectedDate: Date
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 39)
            }
        }
    }
}
