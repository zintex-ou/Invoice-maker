import SwiftUI

struct PreviewView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel: PreviewViewModel
    @Namespace var paidPopover

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.grayF5F5F5
            
            GeneralTemplateView(
                viewModel: .init(
                    templateModel: viewModel.invoice,
                    type: viewModel.invoiceInput.type
                )
            )
            .scrollDisabled(true)
            
            VStack {
                navigationBar
                
                Spacer()
            }
            
            bottomView
        }
        .alert(
            viewModel.alert.title,
            isPresented: $viewModel.shouldShowError) {
                
            } message: {
                Text(viewModel.alert.subtitle)
            }
            .ignoresSafeArea(.container, edges: .bottom)
    }
    
    var navigationBar: some View {
        ZStack {
            HStack {
                Button("") {
                    coordinator.popToBack()
                }
                .buttonStyle(.circle(.property1Cross))
                
                Spacer()
                
                Button {
                    coordinator.pushTo(id: FullscreenPreviewView.navigationID, destination: { FullscreenPreviewView(model: viewModel.invoice, type: viewModel.invoiceInput.type) })
                } label: {
                    Text("Preview")
                        .font(.sans(style: .regular, size: 16))
                        .foregroundStyle(.violet4663FF)
                        .underline()
                }

            }
            
            HStack {
                Spacer()
                
                Text("Invoice")
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
                    Text(viewModel.invoice.header.billTo.name)
                        .font(.sans(style: .semiBold, size: 16))
                        .foregroundStyle(.black)
                    
                    Text("Due date: \(viewModel.invoice.header.invoiceInfo.dueDate)")
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(.black767676)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(viewModel.invoice.summary.currency.rawValue) \(viewModel.invoice.summary.total)")
                        .font(.sans(style: .semiBold, size: 16))
                        .foregroundStyle(.black)
                    
                    Menu {
                        Button("Unpaid") {
                            viewModel.isPaid = false
                            viewModel.isPaidPopShow  = false
                            Task {
                                await viewModel.updateInvoice()
                            }
                        }
                        
                        Button("Paid") {
                            viewModel.isPaid = true
                            viewModel.isPaidPopShow  = false
                            Task {
                                await viewModel.updateInvoice()
                            }
                        }
                    } label: {
                        Button(viewModel.isPaid ? "Paid" : "Unpaid") {
                            viewModel.isPaidPopShow = true
                        }
                        .buttonStyle(
                            .paid(
                                isPaid: $viewModel.isPaid,
                                isPopoverShown: viewModel.isPaidPopShow,
                                namespace: paidPopover,
                                id: viewModel.popoverID
                            )
                        )
                    }
                }
            }
            
            Button("Send invoice") {
                viewModel.sendInvoice()
            }
                .buttonStyle(.main)
                .padding(.vertical, 8)
            
            HStack {
                ShareLink(item: viewModel.pdfFilePath) {
                }
                .buttonStyle(.circle(.property1Share, title: "Share"))
                
                Spacer()

                #warning("Add push to edit invoice")
                Button("") {
                    
                }
                    .buttonStyle(.circle(.property1Edit, title: "Edit"))
                
                Spacer()

                Button("") {
                    Task {
                        await viewModel.deleteInvoice(completion: {
                            coordinator.popToRoot()
                        })
                    }
                }
                    .buttonStyle(.distructiveCircle(.property1Trash, title: "Delete"))
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
        .background {
            Color.white
                .clipShape(
                    RoundedCorners(radius: 16, corners: [.topLeft, .topRight])
                )
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
}
