import SwiftUI

struct TemplateView: View {
    let type: TemplateType
    let templateModel: InvoiceTemplateModel
    
    @StateObject private var topDarkTemplateViewModel: TopDarkTemplateViewModel
    @StateObject private var cleanWhiteTemplateViewModel: СleanWhiteTemplateViewModel
    @StateObject private var minimalTemplateViewModel: MinimalTemplateViewModel
    @StateObject private var corporateTemplateViewModel: CorporateTemplateViewModel
    @StateObject private var classicTemplateViewModel: ClassicTemplateViewModel

    init(type: TemplateType, templateModel: InvoiceTemplateModel) {
        self.type = type
        self.templateModel = templateModel

        _topDarkTemplateViewModel = StateObject(wrappedValue: TopDarkTemplateViewModel(templateModel: templateModel))
        _cleanWhiteTemplateViewModel = StateObject(wrappedValue: СleanWhiteTemplateViewModel(templateModel: templateModel))
        _minimalTemplateViewModel = StateObject(wrappedValue: MinimalTemplateViewModel(templateModel: templateModel))
        _corporateTemplateViewModel = StateObject(wrappedValue: CorporateTemplateViewModel(templateModel: templateModel))
        _classicTemplateViewModel = StateObject(wrappedValue: ClassicTemplateViewModel(templateModel: templateModel))
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
            TopDarkTemplateView(viewModel: topDarkTemplateViewModel)

        case .cleanWhite:
            СleanWhiteTemplateView(viewModel: cleanWhiteTemplateViewModel)
            
        case .minimal:
            MinimalTemplateView(viewModel: minimalTemplateViewModel)
            
        case .classic:
            ClassicTemplateView(viewModel: classicTemplateViewModel)
            
        case .corporate:
            CorporateTemplateView(viewModel: corporateTemplateViewModel)
        }
    }
}
