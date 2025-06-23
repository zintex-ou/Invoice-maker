import SwiftUI

struct GeneralTemplateView: View {
    @ObservedObject var viewModel: GeneralTemplateViewModel
    private let a4Size = CGSize(width: 595, height: 842)

    var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let scale = min(screenSize.width / a4Size.width,
                            screenSize.height / a4Size.height) * 0.9
            let topPadding = (screenSize.height / scale - a4Size.height) / 2
            
            ScrollView {
                pages
                    .frame(
                        width: a4Size.width,
                        height: screenSize.height * CGFloat(viewModel.pages.0.count) * scale,
                        alignment: .top
                    )
                    .padding(.vertical, topPadding)
                    .scaleEffect(scale, anchor: .top)
            }
            .frame(width: screenSize.width, alignment: .top)
        }
    }
    
    private var pages: some View {
        LazyVStack(spacing: 24) {
            ForEach(viewModel.pages.0.indices, id: \.self) { idx in
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)
                    
                    page(at: idx)
                }
                .frame(width: a4Size.width, height: a4Size.height)
            }
        }
    }

    @ViewBuilder
    private func page(at index: Int) -> some View {
        let base = viewModel.templateModel
        let items = viewModel.pages.0[index]
        let tModel = InvoiceTemplateModel(
            id:      base.id,
            header:  base.header,
            summary: base.summary,
            items:   items
        )

        let isFirst = index == 0
        let isLast = index == viewModel.pages.0.count - 1
        let startIndex = viewModel.startIndices[index]

        switch viewModel.type {
        case .topDark:
            if isFirst {
                TopDarkTemplateFirstPageView(
                    templateModel: tModel,
                    customColor: .constant(viewModel.customColor),
                    isWithSummary: viewModel.pages.1
                )
            } else if isLast {
                TopDarkTemplateLastPageView(
                    templateModel: tModel,
                    customColor: .constant(viewModel.customColor),
                    startIndex: startIndex
                )
            } else {
                TopDarkTemplateContinuationPageView(
                    items: items,
                    startIndex: startIndex,
                    customColor: .constant(viewModel.customColor)
                )
            }

        case .cleanWhite:
            if isFirst {
                СleanWhiteTemplateFirstPageView(
                    templateModel: tModel,
                    customColor: .constant(viewModel.customColor),
                    isWithSummary: viewModel.pages.1
                )
            } else if isLast {
                СleanWhiteTemplateLastPageView(
                    templateModel: tModel,
                    customColor: .constant(viewModel.customColor),
                    startIndex: startIndex
                )
            } else {
                СleanWhiteTemplateContinuationPageView(
                    items: items,
                    startIndex: startIndex,
                    customColor: .constant(viewModel.customColor)
                )
            }

        case .minimal:
            if isFirst {
                MinimalTemplateFirstPageView(
                    templateModel: tModel,
                    customColor: .constant(viewModel.customColor),
                    isWithSummary: viewModel.pages.1
                )
            } else if isLast {
                MinimalTemplateLastPageView(
                    templateModel: tModel,
                    customColor: .constant(viewModel.customColor),
                    startIndex: startIndex
                )
            } else {
                MinimalTemplateContinuationView(
                    items: items,
                    startIndex: startIndex,
                    customColor: .constant(viewModel.customColor)
                )
            }

        case .classic:
            if isFirst {
                ClassicTemplateFirstPageView(
                    templateModel: tModel,
                    customColor: .constant(viewModel.customColor),
                    isWithSummary: viewModel.pages.1
                )
            } else if isLast {
                ClassicTemplateLastPageView(
                    templateModel: tModel,
                    customColor: .constant(viewModel.customColor),
                    startIndex: startIndex
                )
            } else {
                ClassicTemplateContinuationView(
                    items: items,
                    startIndex: startIndex,
                    customColor: .constant(viewModel.customColor)
                )
            }

        case .corporate:
            if isFirst {
                CorporateTemplateFirstPageView(
                    templateModel: tModel,
                    customColor: .constant(viewModel.customColor),
                    isWithSummary: viewModel.pages.1
                )
            } else if isLast {
                CorporateTemplateLastPageView(
                    templateModel: tModel,
                    customColor: .constant(viewModel.customColor),
                    startIndex: startIndex
                )
            } else {
                CorporateTemplateContinuationView(
                    items: items,
                    startIndex: startIndex,
                    customColor: .constant(viewModel.customColor)
                )
            }
        }
    }
}
