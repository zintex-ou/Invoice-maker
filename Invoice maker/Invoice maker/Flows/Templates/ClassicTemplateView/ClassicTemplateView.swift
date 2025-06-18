import SwiftUI

struct ClassicTemplateView: View {
    @StateObject var viewModel: ClassicTemplateViewModel
    @State private var selectedColor = Color.gray
    
    var body: some View {
        Group {
            if viewModel.currentPage == 0 {
                ClassicTemplateFirstPageView(
                    templateModel: .init(
                        header: viewModel.templateModel.header,
                        summary: viewModel.templateModel.summary,
                        items: viewModel.pages.0[viewModel.currentPage],
                    ),
                    customColor: .constant(viewModel.customColor),
                    isWithSummary: viewModel.pages.1
                )
            } else if viewModel.currentPage == viewModel.pages.0.count - 1 {
                ClassicTemplateLastPageView(
                    templateModel: .init(
                        header: viewModel.templateModel.header,
                        summary: viewModel.templateModel.summary,
                        items: viewModel.pages.0[viewModel.currentPage]
                    ),
                    customColor: .constant(viewModel.customColor),
                    startIndex: viewModel.startIndices[viewModel.currentPage]
                )
            } else {
                ClassicTemplateContinuationView(
                    items: viewModel.pages.0[viewModel.currentPage],
                    startIndex: viewModel.startIndices[viewModel.currentPage],
                    customColor: .constant(viewModel.customColor),
                )
            }
        }
    }
}
