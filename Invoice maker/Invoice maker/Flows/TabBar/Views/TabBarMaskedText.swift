import SwiftUI

struct TabBarMaskedText: View {
    let text: LocalizedStringKey
    let isVisible: Bool
    @State private var fullWidth: CGFloat = 0

    var body: some View {
        Text(text)
            .font(.sans(style: .semiBold, size: 12))
            .foregroundStyle(.white)
            .fixedSize()
            .background(GeometryReader { geo in
                Color.clear
                    .onAppear { fullWidth = geo.size.width }
            })
            .frame(width: isVisible ? fullWidth : 0, alignment: .leading)
            .clipped()
            .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}
