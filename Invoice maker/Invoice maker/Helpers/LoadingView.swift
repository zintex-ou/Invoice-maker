import SwiftUI

struct LoadingView: View {
    @State var degrees: Double = 0
    
    private let frameSize = 200.0
    private let lineWidth = 10.0
    
    var body: some View {
        ZStack {
            Color.blueDAE0FF.opacity(0.3)
                .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: 24)
                .fill(.blueA0C4FF)
                .opacity(0.8)
                .frame(width: 130, height: 130)
            
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
                .tint(.white)
                
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                degrees += 360
            }
        }
    }
}

#Preview {
    LoadingView()
    
}
