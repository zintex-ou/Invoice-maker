import SwiftUI

struct ItemsServicesListView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @StateObject var viewModel: ItemsServicesListViewModel
    
    init(viewModel: ItemsServicesListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.bottom, 4)
            
            SegmentedControl(
                selection: $viewModel.offerSelection,
                segments: SegmentOfferType.allCases
            )
            .padding(.top, 24)
            .padding(.bottom, 4)
            
            if (viewModel.items.isEmpty && viewModel.offerSelection == .items) || (viewModel.services.isEmpty && viewModel.offerSelection == .services) {
                emptyView
            } else {
                list
            }
            
            HStack {
                Button(viewModel.buttonTitle()) {
                    coordinator.pushTo(
                        id: AddNewItemServiceView.navigationID,
                        destination: { AddNewItemServiceView(
                            viewModel: .init(
                                offerType: viewModel.offerSelection,
                                viewState: .initial
                            )
                        )
                        })
                }
                .buttonStyle(.main)
            }
            .padding(.vertical, 8)
            .background(.white)
        }
        .padding(.horizontal, 16)
        .task {
            await viewModel.fetchItemsServices()
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
            
            Text("Add \(viewModel.offerSelection == .items ? "item" : "service") details once and create\ninvoices in just a few clicks.")
                .font(.sans(style: .regular, size: 16))
                .foregroundStyle(.black767676)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
    
    var list: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 12) {
                    let model = viewModel.offerSelection == .items ? viewModel.items : viewModel.services
                    
                    ForEach(model, id: \.self) { item in
                        Button {
                            tapOnItemsServices(item)
                        } label: {
                            ItemServiceViewCell(
                                itemService: item,
                                isSelectedCell: viewModel.isSelectedCell(item),
                                offerSelection: viewModel.offerSelection,
                                viewType: viewModel.viewType) {
                                    viewModel.deleteItemService(item)
                                }
                        }
                    }
                }
                .animation(.default, value: viewModel.items.count)
                .animation(.default, value: viewModel.services.count)
                .padding(.top, 24)
                .padding(.bottom, 70)
            }
            .scrollIndicators(.hidden)
            
            ListTopShadow()
        }
    }
    
    private func tapOnItemsServices(_ item: ItemServiceEntity) {
        switch viewModel.viewType {
        case .choiseItemsOrServices:
            viewModel.postSelectedItemService(item)
            coordinator.popToBack()
        case .editItemsOrServices:
            coordinator.pushTo(
                id: AddNewItemServiceView.navigationID,
                destination: {
                    AddNewItemServiceView(
                        viewModel: .init(
                            offerType: viewModel.offerSelection,
                            viewState: .editing(entity: item)
                        )
                    )
                })
        }
    }
}

#Preview {
    ItemsServicesListView(viewModel: .init(viewType: .editItemsOrServices))
}
