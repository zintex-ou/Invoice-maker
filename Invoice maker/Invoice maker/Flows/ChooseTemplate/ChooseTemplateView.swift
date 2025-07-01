import SwiftUI

struct ChooseTemplateView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel: ChooseTemplateViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            navigationBar
            
            Text("Choose template")
                .font(.sans(style: .semiBold, size: 26))
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            templatePicker
            
            HStack(spacing: 8) {
                ForEach(0..<TemplateType.allCases.count, id: \.self) { index in
                    let isSelected = index == viewModel.templateIndex
                    
                    Circle()
                        .fill(isSelected ? .violet4663FF : .black767676.opacity(0.4))
                        .frame(width: isSelected ? 12 : 8, height: isSelected ? 12 : 8)
                }
            }
            .padding(.bottom, 32)
            
            if viewModel.invoiceType == .invoice {
                colorPicker
                    .padding(.horizontal, 16)
            }
            
            Button("Save") {
                if viewModel.isPremium || viewModel.isFreeGeneratedInvoice {
                    Task {
                        await viewModel.saveTemplate { invoiceEntity in
                            coordinator.pushTo(
                                id: PreviewView.navigationID,
                                destination: {
                                    PreviewView(viewModel: .init(invoiceEntity: invoiceEntity))
                                }
                            )
                        }
                    }
                } else {
                    coordinator.presentFullScreenCover(id: PaywallView.navigationID) {
                        PaywallView()
                    }
                }
            }
            .buttonStyle(.main)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .alert("Are you sure you want to leave?",
               isPresented: $viewModel.isShowDeleteAlert) {
            Button("Save", role: .cancel) {
                Task {
                    await viewModel.saveTemplate(completion: { invoiceEntity in
                        coordinator
                            .pushTo(
                                id: PreviewView.navigationID,
                                destination: { PreviewView(
                                    viewModel: .init(
                                        invoiceEntity: invoiceEntity
                                    )
                                )
                                })
                    })
                }
            }
            
            Button("Leave", role: .destructive) {
                coordinator.popTo(id: TabBarView.navigationID)
            }
            
        } message: {
            Text("You have unsaved changes. If you close this invoice, all data will be lost.")
        }
        .alert(
            viewModel.alert.title,
            isPresented: $viewModel.shouldShowError) {
                
            } message: {
                Text(viewModel.alert.subtitle)
            }
    }
    
    private var navigationBar: some View {
        ZStack {
            HStack {
                Button("") {
                    coordinator.popToBack()
                }
                .buttonStyle(.circle(.property1Arrow))
                
                Spacer()
                
                Button {
                    viewModel.onCancelTapped()
                } label: {
                    Text("Cancel")
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
    
    private var templatePicker: some View {
        TabView(selection: $viewModel.templateIndex) {
            ForEach(Array(TemplateType.allCases.enumerated()), id: \.1.rawValue) { index, type in
                Image(viewModel.templateImageWithCustomColor(customColor: viewModel.customColor, type: type))
                    .resizable()
                    .overlay(
                        Rectangle().stroke(.violet4663FF, lineWidth: viewModel.templateType == type ? 2 : 0)
                    )
                    .shadow(color: Color(red: 0.15, green: 0.19, blue: 0.3).opacity(0.15), radius: 4.61176, x: 0, y: 4.61176)
                    .onTapGesture {
                        withAnimation {
                            viewModel.templateType = type
                        }
                    }
                    .frame(width: viewModel.invoiceType == .invoice ? 240 : nil, height: viewModel.invoiceType == .invoice ? 340 : nil)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .padding(.top, 24)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Colors")
                .font(.sans(style: .semiBold, size: 26))
                .foregroundStyle(.black)
            
            HStack(spacing: 0) {
                ForEach(Array(CustomColors.allCases.enumerated()), id: \.1) { index, color in
                    Circle()
                        .fill(color.color)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle().stroke(.violet4663FF, lineWidth: viewModel.customColor == color ? 2 : 0)
                        )
                        .onTapGesture {
                            withAnimation {
                                viewModel.customColor = color
                            }
                        }
                    
                    if index < CustomColors.allCases.count - 1 {
                        Spacer()
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 34)
            .frame(width: UIScreen.main.bounds.width - 36)
        }
    }
}
