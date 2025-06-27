import SwiftUI

struct FullscreenPreviewView: View {
    @EnvironmentObject private var coordinator: Coordinator
    var url: URL
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            PDFKitView(url: url, withScroll: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .layoutPriority(1)
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private var navigationBar: some View {
        ZStack {
            HStack {
                Button("") {
                    coordinator.popToBack()
                }
                .buttonStyle(.circle(.property1Arrow))
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Text("Preview")
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
            }
        }
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
        .background(.white)
    }
}
