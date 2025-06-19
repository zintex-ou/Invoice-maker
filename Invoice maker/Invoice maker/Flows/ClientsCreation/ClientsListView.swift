import SwiftUI

struct ClientsListView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @StateObject var viewModel: ClientsListViewModel = .init()
    
    var body: some View {
        VStack {
            navigationBar
            
            if viewModel.clients.isEmpty {
                emptyView
            } else {
                list
            }
            
            Button("Add new client") {
                coordinator.pushTo(id: AddNewClientView.navigationID, destination: { AddNewClientView() })
            }
            .buttonStyle(.main)
        }
        .padding(.horizontal, 16)
        .onAppear(perform: {
            Task { await viewModel.fetchClients() }
        })
        .alert("Delete Client",
               isPresented: $viewModel.isShowDeleteAlert) {
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Delete", role: .destructive) {
                if let clientToDelete = viewModel.clientToDelete {
                    Task { await viewModel.deleteClient(clientToDelete) }
                }
            }

        } message: {
            Text("Are you sure you want to delete this client? ")
        }
        .alert("Error",
               isPresented: $viewModel.showErrorAlert) {
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text(viewModel.errorAlertSubtitle)
        }
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
    
    var list: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.clients, id: \.id) { client in
                    Button("") {
                        coordinator.pushTo(id: EditClientView.navigationID, destination: {
                            EditClientView(
                                viewModel: .init(client: client)
                            )
                        })
                    }
                    .buttonStyle(
                        .clientCellWithActions(
                            clientName: client.clientName ?? "",
                            clientEmail: client.email ?? "",
                            editAction: {
                                coordinator.pushTo(id: EditClientView.navigationID, destination: {
                                    EditClientView(
                                        viewModel: .init(client: client)
                                    )
                                })
                            },
                            deleteAction: {
                                viewModel.showDeleteAlert(for: client)
                            }
                        )
                    )
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    ClientsListView()
}
