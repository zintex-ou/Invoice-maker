import SwiftUI

struct ClientsListView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {
        VStack {
            navigationBar
            
            emptyView
            
            Button("Add new client") {
                withAnimation {
                    coordinator.presentFullScreenCover(id: AddNewClientView.navigationID, content: { AddNewClientView() })
                }
            }
            .buttonStyle(MainButton())
        }
        .padding(.horizontal, 16)
    }
    
    var navigationBar: some View {
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
                
                Text("Clients")
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
            }
        }
    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            
            Image(.property1Client)
                .resizable()
                .frame(width: 32, height: 32)
                .padding(12)
                .background {
                    Circle()
                        .fill(.grayF5F5F5)
                }
            
            Text("Clients")
                .font(.sans(style: .semiBold, size: 26))
                .foregroundStyle(.black)
        
            Text("Add client details once and create\ninvoices in just a few clicks.")
                .font(.sans(style: .regular, size: 16))
                .foregroundStyle(.black767676)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

#Preview {
    ClientsListView()
}
