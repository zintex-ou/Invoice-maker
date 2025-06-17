import SwiftUI

struct EditClientView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @StateObject var viewModel: EditClientViewModel
    
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
            
            Button("Save") {
                viewModel.onSaveTapped {
                    coordinator.dismissFullScreenCover()
                }
            }
            .buttonStyle(.main)
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
        .alert("Delete Item",
               isPresented: $viewModel.isShowDeleteAlert) {
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Delete", role: .destructive) {
                viewModel.deleteClient()
                coordinator.dismissFullScreenCover()
            }
            
        } message: {
            Text("Are you sure you want to delete this item? ")
        }
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
                    viewModel.onCloseTapped() {
                        coordinator.dismissFullScreenCover()
                    }
                }
                .buttonStyle(.circle(.property1Cross))
                
                Spacer()
                
                Text("Edit client")
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
                
                Button("") {
                    viewModel.showDeleteAlert()
                }
                .buttonStyle(.distructiveCircle(.property1Trash))
            }
        }
    }
}
