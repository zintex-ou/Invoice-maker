import SwiftUI

struct MinimalTemplateView: View {
    @StateObject var viewModel: MinimalTemplateViewModel
 
    private let a4Size = CGSize(width: 595, height: 842)
    
    var body: some View {
        LazyVStack(spacing: 24) {
            ForEach(viewModel.pages.0.indices, id: \.self) { index in
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15),
                                radius: 12, x: 0, y: 8)
                    
                    page(at: index)
                        .frame(width: a4Size.width,
                               height: a4Size.height)
                }
                .frame(width: a4Size.width,
                       height: a4Size.height)
            }
        }
    }
    
    @ViewBuilder
    private func page(at index: Int) -> some View {
        if index == 0 {
            MinimalTemplateFirstPageView(
                templateModel: .init(
                    id: viewModel.templateModel.id,
                    header:  viewModel.templateModel.header,
                    summary: viewModel.templateModel.summary,
                    items:   viewModel.pages.0[index]
                ),
                customColor: .constant(viewModel.customColor),
                isWithSummary: viewModel.pages.1
            )
        } else if index == viewModel.pages.0.count - 1 {
            MinimalTemplateLastPageView(
                templateModel: .init(
                    id: viewModel.templateModel.id,
                    header:  viewModel.templateModel.header,
                    summary: viewModel.templateModel.summary,
                    items:   viewModel.pages.0[index]
                ),
                customColor: .constant(viewModel.customColor),
                startIndex: viewModel.startIndices[viewModel.currentPage]
            )
        } else {
            MinimalTemplateContinuationView(
                items: viewModel.pages.0[viewModel.currentPage],
                startIndex: viewModel.startIndices[viewModel.currentPage],
                customColor: .constant(viewModel.customColor),
            )
        }
    }
}
