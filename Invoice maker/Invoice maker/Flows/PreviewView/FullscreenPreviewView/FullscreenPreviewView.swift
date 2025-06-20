import SwiftUI
 
struct FullscreenPreviewView: View {
    @EnvironmentObject private var coordinator: Coordinator
    var model: InvoiceTemplateModel
    var type: TemplateType
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.grayF5F5F5
            
            TemplateView(
                type: type,
                templateModel: model
            )
            
            VStack {
                navigationBar
                
                Spacer()
            }
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
