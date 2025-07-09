import SwiftUI

struct PreviewView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel: PreviewViewModel
    @Namespace var paidPopover
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Color.grayF5F5F5
            
            VStack(spacing: 0) {
                navigationBar
                
                GeometryReader { geometryProxy in
                    PDFPageView(
                        url: viewModel.pdfFilePath,
                        pageNumber: 0
                    )
                    .padding(16)
                    .frame(width: geometryProxy.size.width, height: geometryProxy.size.width * 1.414)
                }
            }
            
            bottomView
        }
        .alert(
            viewModel.alert.title,
            isPresented: $viewModel.shouldShowError) {
                
            } message: {
                Text(viewModel.alert.subtitle)
            }
            .alert("Delete client",
                   isPresented: $viewModel.isShowDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    
                }
                
                Button("Delete", role: .destructive) {
                    viewModel.deleteInvoice(completion: {
                        coordinator.popTo(id: TabBarView.navigationID)
                    })
                }
                
            } message: {
                Text("Are you sure you want to delete this client? ")
            }
            .ignoresSafeArea(.container, edges: .bottom)
    }
    
    var navigationBar: some View {
        ZStack {
            HStack {
                Button("") {
                    coordinator.popTo(id: TabBarView.navigationID)
                }
                .buttonStyle(.circle(.property1Arrow))
                
                Spacer()
                
                Button {
                    coordinator
                        .pushTo(
                            id: FullscreenPreviewView.navigationID,
                            destination: { FullscreenPreviewView(
                                url: viewModel.pdfFilePath
                            )
                            })
                } label: {
                    Text("Preview")
                        .font(.sans(style: .regular, size: 16))
                        .foregroundStyle(.violet4663FF)
                        .underline()
                }
                
            }
            
            HStack {
                Spacer()
                
                Text(viewModel.title())
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
            }
        }
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
        .background(.white)
    }
    
    var bottomView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.name())
                        .font(.sans(style: .semiBold, size: 16))
                        .foregroundStyle(.black)
                    
                    Text(viewModel.dueDate())
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(.black767676)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(viewModel.total())
                        .font(.sans(style: .semiBold, size: 16))
                        .foregroundStyle(.black)
                    
                    if viewModel.isInvoice {
                        Menu {
                            Button {
                                viewModel.tapOnMenuButton(false)
                            } label: {
                                HStack {
                                    Text("Unpaid")
                                        .font(.sans(style: .regular, size: 17))
                                    
                                    if !viewModel.isPaid {
                                        Image(.property1Tick)
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                    }
                                }
                            }
                            
                            Button {
                                viewModel.tapOnMenuButton(true)
                            } label: {
                                HStack {
                                    Text("Paid")
                                        .font(.sans(style: .regular, size: 17))
                                    
                                    if viewModel.isPaid {
                                        Image(.property1Tick)
                                            .resizable()
                                            .renderingMode(.template)
                                            .frame(width: 12, height: 12)
                                            .foregroundStyle(.violet4663FF)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 2) {
                                Text(viewModel.isPaid ? "Paid" : "Unpaid")
                                    .foregroundStyle(.black)
                                    .font(.sans(style: .regular, size: 12))
                                
                                
                                Image(.discountArrow)
                                    .resizable()
                                    .frame(width: 12, height: 12)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(viewModel.isPaid ? .greenB4F5C4 : .blueDAE0FF)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Button(viewModel.buttonTitle()) {
                viewModel.sendInvoice(completion: { isSent in
                    if isSent {
                        coordinator.popTo(id: TabBarView.navigationID)
                    }
                })
            }
            .buttonStyle(.main)
            .padding(.vertical, 8)
            
            HStack {
                ShareLink(item: viewModel.pdfFilePath) {
                }
                .buttonStyle(.circle(.property1Share, title: "Share"))
                
                Spacer()
                
                Button("") {
                    coordinator.pushTo(id: CreateInvoiceView.navigationID) {
                        let viewModel = CreateInvoiceViewModel(
                            viewType: viewModel.isInvoice ? .editInvoice(viewModel.invoiceEntity) : .editEstimate(viewModel.invoiceEntity)
                        )
                        return CreateInvoiceView(viewModel: viewModel)
                    }
                }
                .buttonStyle(.circle(.property1Edit, title: "Edit"))
                
                Spacer()
                
                if !viewModel.isInvoice {
                    Button("") {
                        coordinator.pushTo(id: CreateInvoiceView.navigationID) {
                            let viewModel = CreateInvoiceViewModel(
                                viewType: .convertEstimateToInvoice(viewModel.invoiceEntity)
                            )
                            return CreateInvoiceView(viewModel: viewModel)
                        }
                    }
                    .buttonStyle(.circle(.property1Invoices, title: "Convert"))
                    
                    Spacer()
                }
                
                Button("") {
                    viewModel.showDeleteAlert()
                }
                .buttonStyle(.distructiveCircle(.property1Trash, title: "Delete"))
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
        .animation(.default, value: viewModel.isPaid)
        .background {
            Color.white
                .clipShape(
                    RoundedCorners(radius: 16, corners: [.topLeft, .topRight])
                )
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
}
