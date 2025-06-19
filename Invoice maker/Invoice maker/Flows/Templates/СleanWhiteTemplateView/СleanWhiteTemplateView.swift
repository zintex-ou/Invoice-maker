import SwiftUI

struct СleanWhiteTemplateView: View {
    @StateObject var viewModel: СleanWhiteTemplateViewModel
    
    var body: some View {
        Group {
            if viewModel.currentPage == 0 {
                СleanWhiteTemplateFirstPageView(
                    templateModel: .init(
                        header: viewModel.templateModel.header,
                        summary: viewModel.templateModel.summary,
                        items: viewModel.pages.0[viewModel.currentPage],
                    ),
                    customColor: .constant(viewModel.customColor),
                    isWithSummary: viewModel.pages.1
                )
            } else if viewModel.currentPage == viewModel.pages.0.count - 1 {
                СleanWhiteTemplateLastPageView(
                    templateModel: .init(
                        header: viewModel.templateModel.header,
                        summary: viewModel.templateModel.summary,
                        items: viewModel.pages.0[viewModel.currentPage]
                    ),
                    customColor: .constant(viewModel.customColor),
                    startIndex: viewModel.startIndices[viewModel.currentPage]
                )
            } else {
                СleanWhiteTemplateContinuationPageView(
                    items: viewModel.pages.0[viewModel.currentPage],
                    startIndex: viewModel.startIndices[viewModel.currentPage],
                    customColor: .constant(viewModel.customColor),
                )
            }
        }
    }
}
