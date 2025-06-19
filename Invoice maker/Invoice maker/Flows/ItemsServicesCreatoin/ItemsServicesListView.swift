import SwiftUI

struct ItemsServicesListView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @StateObject var viewModel: ItemsServicesListViewModel = .init()
    
    var body: some View {
        VStack {
            navigationBar
            
            SegmentedControl(
                selection: $viewModel.offerSelection,
                segments: SegmentOfferType.allCases
            )
            
            if (viewModel.items.isEmpty && viewModel.offerSelection == .items) || (viewModel.services.isEmpty && viewModel.offerSelection == .services) {
                emptyView
            } else {
                list
            }
            
            Button(viewModel.buttonTitle()) {
                coordinator.pushTo(id: AddNewItemServiceView.navigationID, destination: { AddNewItemServiceView(viewModel: .init(offerType: viewModel.offerSelection)) })
            }
            .buttonStyle(.main)
        }
        .padding(.horizontal, 16)
        .onAppear(perform: {
            Task { await viewModel.fetchItemsServices() }
        })
        .alert(viewModel.alertDeleteTitle(),
               isPresented: $viewModel.isShowDeleteAlert) {
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Delete", role: .destructive) {
                if let itemToDelete = viewModel.itemToDelete {
                    Task { await viewModel.deleteItemService(itemToDelete) }
                }
            }

        } message: {
            Text(viewModel.alertDeleteMessage())
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
                
                Text("Items&services")
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
            }
        }
    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            
            Image(viewModel.offerSelection == .items ? .property1Item : .property1Service2)
                .resizable()
                .frame(width: 32, height: 32)
                .padding(12)
                .background {
                    Circle()
                        .fill(.grayF5F5F5)
                }
            
            Text(viewModel.offerSelection == .items ? "Items" : "Services")
                .font(.sans(style: .semiBold, size: 26))
                .foregroundStyle(.black)
        
            Text("Add \(viewModel.offerSelection == .items ? "item" : "service") details once and create invoices in just a few clicks.")
                .font(.sans(style: .regular, size: 16))
                .foregroundStyle(.black767676)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
    
#warning("Change curency dinamically")
    var list: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.offerSelection == .items ? viewModel.items : viewModel.services, id: \.id) { item in
                    Button("") {
                        coordinator.pushTo(id: EditItemServiceView.navigationID, destination: {
                            EditItemServiceView(
                                viewModel: .init(itemService: item)
                            )
                        })
                    }
                    .buttonStyle(
                        .itemCell(
                            itemName: item.name ?? "",
                            discountType: DiscountType(rawValue: item.discountType ?? "") ?? .none,
                            discont: "\(item.discount ?? "")",
                            tax: "\(item.tax ?? "")",
                            total: item.price ?? "",
                            currency: .USD,
                            editAction: {
                                coordinator.pushTo(id: EditItemServiceView.navigationID, destination: {
                                    EditItemServiceView(
                                        viewModel: .init(itemService: item)
                                    )
                                })
                            },
                            deleteAction: {
                                viewModel.showDeleteAlert(for: item)
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
    ItemsServicesListView()
}
