import SwiftUI

struct ToggleDetailsButton: View {
    @Binding var isExpanded: Bool
  
    var expandedText: String = "Hide details"
    var collapsedText: String = "More details"
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                Text(isExpanded ? expandedText : collapsedText)
                    .font(.sans(style: .regular, size: 16))
                    .foregroundStyle(.violet4663FF)
                    .underline()
            }
        }
        .padding(.bottom, 12)
    }
}
