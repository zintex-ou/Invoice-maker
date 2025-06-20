import SwiftUI

struct TemplateView: View {
    let type: TemplateType
    let templateModel: InvoiceTemplateModel

    init(type: TemplateType, templateModel: InvoiceTemplateModel) {
        self.type = type
        self.templateModel = templateModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let a4Size = CGSize(width: 595, height: 842)
            let scale = min(screenSize.width / a4Size.width,
                            screenSize.height / a4Size.height) * 0.9
            let topPadding = (screenSize.height / scale - a4Size.height) / 2
            ScrollView {
                content()
                    .frame(width: a4Size.width, height: a4Size.height)
                    .padding(.vertical, topPadding)
                    .scaleEffect(scale)
            }
            .frame(width: screenSize.width, height: screenSize.height)
        }
    }
    
    @ViewBuilder
    private func content() -> some View {
        switch type {
        case .topDark:
            TopDarkTemplateView(viewModel: .init(templateModel: templateModel, type: .topDark))

        case .cleanWhite:
            СleanWhiteTemplateView(viewModel: .init(templateModel: templateModel, type: .cleanWhite))
            
        case .minimal:
            MinimalTemplateView(viewModel: .init(templateModel: templateModel, type: .minimal))
            
        case .classic:
            ClassicTemplateView(viewModel: .init(templateModel: templateModel, type: .classic))
            
        case .corporate:
            CorporateTemplateView(viewModel: .init(templateModel: templateModel, type: .corporate))
        }
    }
}
