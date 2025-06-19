import SwiftUI

struct TopDarkTemplateView: View {
    @StateObject var viewModel: TopDarkTemplateViewModel
    
    var body: some View {
        Group {
            if viewModel.currentPage == 0 {
                TopDarkTemplateFirstPageView(
                    templateModel: .init(
                        header: viewModel.templateModel.header,
                        summary: viewModel.templateModel.summary,
                        items: viewModel.pages.0[viewModel.currentPage],
                    ),
                    customColor: .constant(viewModel.customColor),
                    isWithSummary: viewModel.pages.1
                )
            } else if viewModel.currentPage == viewModel.pages.0.count - 1 {
                TopDarkTemplateLastPageView(
                    templateModel: .init(
                        header: viewModel.templateModel.header,
                        summary: viewModel.templateModel.summary,
                        items: viewModel.pages.0[viewModel.currentPage]
                    ),
                    customColor: .constant(viewModel.customColor),
                    startIndex: viewModel.startIndices[viewModel.currentPage]
                )
            } else {
                TopDarkTemplateContinuationPageView(
                    items: viewModel.pages.0[viewModel.currentPage],
                    startIndex: viewModel.startIndices[viewModel.currentPage],
                    customColor: .constant(viewModel.customColor),
                )
            }
        }
    }
}
