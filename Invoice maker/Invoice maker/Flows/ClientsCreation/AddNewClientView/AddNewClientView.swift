import SwiftUI

struct AddNewClientView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @StateObject var viewModel: AddNewClientViewModel = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.bottom, 24)
            
            AddClientView(
                nameError: $viewModel.nameError,
                eMailError: $viewModel.eMailError,
                client: $viewModel.clientInput,
                isExpanded: $viewModel.isExpanded
            )
            
            Button("Add new client") {
                viewModel.onSaveTapped {
                    coordinator.dismissFullScreenCover()
                }
            }
            .buttonStyle(.main)
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
        .alert("Save before leaving?",
               isPresented: $viewModel.showLeaveWithoutSavingAlert) {
            Button("Leave", role: .cancel) {
                coordinator.dismissFullScreenCover()
            }
            
            Button("Save", role: .destructive) {
                viewModel.onSaveTapped {
                    coordinator.dismissFullScreenCover()
                }
            }
            
        } message: {
            Text("If you close this client, all changes will be lost.")
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
                    viewModel.onCloseTapped {
                        coordinator.dismissFullScreenCover()
                    }
                }
                .buttonStyle(.circle(.property1Cross))
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Text("Add new client")
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
            }
        }
    }
}
