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
                Task {
                    await viewModel.saveTemplate(completion: { invoice, invoiceInput, invoiceEntity in
                        coordinator
                            .pushTo(
                                id: PreviewView.navigationID,
                                destination: { PreviewView(
                                    viewModel: .init(
                                        invoiceInput: invoiceInput,
                                        invoiceEntity: invoiceEntity,
                                        invoice: invoice,
                                        customColor: viewModel.customColor.color
                                    )
                                )
                                })
                    })
                }
            }
            .buttonStyle(.main)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .alert("Delete Item",
               isPresented: $viewModel.isShowDeleteAlert) {
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Delete", role: .destructive) {
                coordinator.popTo(id: TabBarView.navigationID)
            }
            
        } message: {
            Text("Are you sure you want to delete this item? ")
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
                    .frame(width: 240, height: 340)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 360)
        .padding(.top, 24)
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
