import SwiftUI

struct CorporateTemplateView: View {
    @StateObject var viewModel: CorporateTemplateViewModel
    
    var body: some View {
        Group {
            if viewModel.currentPage == 0 {
                CorporateTemplateFirstPageView(
                    templateModel: .init(
                        header: viewModel.templateModel.header,
                        summary: viewModel.templateModel.summary,
                        items: viewModel.pages.0[viewModel.currentPage],
                    ),
                    customColor: .constant(viewModel.customColor),
                    isWithSummary: viewModel.pages.1
                )
            } else if viewModel.currentPage == viewModel.pages.0.count - 1 {
                CorporateTemplateLastPageView(
                    templateModel: .init(
                        header: viewModel.templateModel.header,
                        summary: viewModel.templateModel.summary,
                        items: viewModel.pages.0[viewModel.currentPage]
                    ),
                    customColor: .constant(viewModel.customColor),
                    startIndex: viewModel.startIndices[viewModel.currentPage]
                )
            } else {
                CorporateTemplateContinuationView(
                    items: viewModel.pages.0[viewModel.currentPage],
                    startIndex: viewModel.startIndices[viewModel.currentPage],
                    customColor: .constant(viewModel.customColor),
                )
            }
        }
    }
}
