import SwiftUI

struct RadioButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(.violet4663FF)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .foregroundStyle(.violet4663FF)
                            .frame(width: 12, height: 12)
                    }
                }
                Text(label)
                    .font(.sans(style: .regular, size: 16))
                    .foregroundColor(.black)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
