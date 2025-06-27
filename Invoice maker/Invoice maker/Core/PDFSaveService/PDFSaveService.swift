import SwiftUI

final class PDFSaveService {
    private let pageSize = CGSize(width: 595, height: 842)
    private let fileManagerPDFService = FileManagerPDFService()
    
    @discardableResult
    func generateAndSave(
        type: TemplateType,
        templateModel: InvoiceTemplateModel,
        customColor: Color,
        invoiceType: InvoiceType
    ) throws -> URL {
        let (pageCount, pageRenderer) = try prepareRenderer(type: type,
                                                            model: templateModel,
                                                            customColor: customColor)
        
        let pdfData = renderPDF(pageCount: pageCount,
                                pageRenderer: pageRenderer)
        
        return try fileManagerPDFService.savePDF(data: pdfData, for: invoiceType)
    }
    
    private func prepareRenderer(
        type: TemplateType,
        model: InvoiceTemplateModel,
        customColor: Color
    ) throws -> (pageCount: Int, pageRenderer: (Int) -> AnyView) {
        switch type {
        case .topDark:
            let vm = GeneralTemplateViewModel(templateModel: model, type: .topDark, customColor: customColor)
            return (
                vm.pages.0.count,
                makeTopDarkRenderer(vm: vm, color: customColor)
            )
        case .cleanWhite:
            let vm = GeneralTemplateViewModel(templateModel: model, type: .cleanWhite, customColor: customColor)
            return (
                vm.pages.0.count,
                makeCleanWhiteRenderer(vm: vm, color: customColor)
            )
        case .minimal:
            let vm = GeneralTemplateViewModel(templateModel: model, type: .minimal, customColor: customColor)
            return (
                vm.pages.0.count,
                makeMinimalRenderer(vm: vm, color: customColor)
            )
        case .classic:
            let vm = GeneralTemplateViewModel(templateModel: model, type: .classic, customColor: customColor)
            return (
                vm.pages.0.count,
                makeClassicRenderer(vm: vm, color: customColor)
            )
        case .corporate:
            let vm = GeneralTemplateViewModel(templateModel: model, type: .corporate, customColor: customColor)
            return (
                vm.pages.0.count,
                makeCorporateRenderer(vm: vm, color: customColor)
            )
        }
    }
    
    private func makeTopDarkRenderer(
        vm: GeneralTemplateViewModel,
        color: Color
    ) -> (Int) -> AnyView {
        return { idx in
            if idx == 0 {
                return AnyView(TopDarkTemplateFirstPageView(
                    templateModel: .init(
                        id: vm.templateModel.id,
                        header: vm.templateModel.header,
                        summary: vm.templateModel.summary,
                        items: vm.pages.0[idx]
                    ),
                    customColor: .constant(color),
                    isWithSummary: vm.pages.1
                ))
            } else if idx == vm.pages.0.count - 1 {
                return AnyView(TopDarkTemplateLastPageView(
                    templateModel: .init(
                        id: vm.templateModel.id,
                        header: vm.templateModel.header,
                        summary: vm.templateModel.summary,
                        items: vm.pages.0[idx]
                    ),
                    customColor: .constant(color),
                    startIndex: vm.startIndices[idx]
                ))
            } else {
                return AnyView(TopDarkTemplateContinuationPageView(
                    items: vm.pages.0[idx],
                    startIndex: vm.startIndices[idx],
                    customColor: .constant(color)
                ))
            }
        }
    }
    
    private func makeCleanWhiteRenderer(
        vm: GeneralTemplateViewModel,
        color: Color
    ) -> (Int) -> AnyView {
        return { idx in
            if idx == 0 {
                return AnyView(СleanWhiteTemplateFirstPageView(
                    templateModel: .init(
                        id: vm.templateModel.id,
                        header: vm.templateModel.header,
                        summary: vm.templateModel.summary,
                        items: vm.pages.0[idx]
                    ),
                    customColor: .constant(color),
                    isWithSummary: vm.pages.1
                ))
            } else if idx == vm.pages.0.count - 1 {
                return AnyView(СleanWhiteTemplateLastPageView(
                    templateModel: .init(
                        id: vm.templateModel.id,
                        header: vm.templateModel.header,
                        summary: vm.templateModel.summary,
                        items: vm.pages.0[idx]
                    ),
                    customColor: .constant(color),
                    startIndex: vm.startIndices[idx]
                ))
            } else {
                return AnyView(СleanWhiteTemplateContinuationPageView(
                    items: vm.pages.0[idx],
                    startIndex: vm.startIndices[idx],
                    customColor: .constant(color)
                ))
            }
        }
    }
    
    private func makeMinimalRenderer(
        vm: GeneralTemplateViewModel,
        color: Color
    ) -> (Int) -> AnyView {
        return { idx in
            if idx == 0 {
                return AnyView(MinimalTemplateFirstPageView(
                    templateModel: .init(
                        id: vm.templateModel.id,
                        header: vm.templateModel.header,
                        summary: vm.templateModel.summary,
                        items: vm.pages.0[idx]
                    ),
                    customColor: .constant(color),
                    isWithSummary: vm.pages.1
                ))
            } else if idx == vm.pages.0.count - 1 {
                return AnyView(MinimalTemplateLastPageView(
                    templateModel: .init(
                        id: vm.templateModel.id,
                        header: vm.templateModel.header,
                        summary: vm.templateModel.summary,
                        items: vm.pages.0[idx]
                    ),
                    customColor: .constant(color),
                    startIndex: vm.startIndices[idx]
                ))
            } else {
                return AnyView(MinimalTemplateContinuationView(
                    items: vm.pages.0[idx],
                    startIndex: vm.startIndices[idx],
                    customColor: .constant(color)
                ))
            }
        }
    }
    
    private func makeClassicRenderer(
        vm: GeneralTemplateViewModel,
        color: Color
    ) -> (Int) -> AnyView {
        return { idx in
            if idx == 0 {
                return AnyView(ClassicTemplateFirstPageView(
                    templateModel: .init(
                        id: vm.templateModel.id,
                        header: vm.templateModel.header,
                        summary: vm.templateModel.summary,
                        items: vm.pages.0[idx]
                    ),
                    customColor: .constant(color),
                    isWithSummary: vm.pages.1
                ))
            } else if idx == vm.pages.0.count - 1 {
                return AnyView(ClassicTemplateLastPageView(
                    templateModel: .init(
                        id: vm.templateModel.id,
                        header: vm.templateModel.header,
                        summary: vm.templateModel.summary,
                        items: vm.pages.0[idx]
                    ),
                    customColor: .constant(color),
                    startIndex: vm.startIndices[idx]
                ))
            } else {
                return AnyView(ClassicTemplateContinuationView(
                    items: vm.pages.0[idx],
                    startIndex: vm.startIndices[idx],
                    customColor: .constant(color)
                ))
            }
        }
    }
    
    private func makeCorporateRenderer(
        vm: GeneralTemplateViewModel,
        color: Color
    ) -> (Int) -> AnyView {
        return { idx in
            if idx == 0 {
                return AnyView(CorporateTemplateFirstPageView(
                    templateModel: .init(
                        id: vm.templateModel.id,
                        header: vm.templateModel.header,
                        summary: vm.templateModel.summary,
                        items: vm.pages.0[idx]
                    ),
                    customColor: .constant(color),
                    isWithSummary: vm.pages.1
                ))
            } else if idx == vm.pages.0.count - 1 {
                return AnyView(CorporateTemplateLastPageView(
                    templateModel: .init(
                        id: vm.templateModel.id,
                        header: vm.templateModel.header,
                        summary: vm.templateModel.summary,
                        items: vm.pages.0[idx]
                    ),
                    customColor: .constant(color),
                    startIndex: vm.startIndices[idx]
                ))
            } else {
                return AnyView(CorporateTemplateContinuationView(
                    items: vm.pages.0[idx],
                    startIndex: vm.startIndices[idx],
                    customColor: .constant(color)
                ))
            }
        }
    }
    
    private func renderPDF(
        pageCount: Int,
        pageRenderer: (Int) -> AnyView
    ) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return renderer.pdfData { ctx in
            for idx in 0..<pageCount {
                ctx.beginPage()
                let view = pageRenderer(idx)
                    .frame(width: pageSize.width,
                           height: pageSize.height,
                           alignment: .top)
                let host = UIHostingController(rootView: view)
                host.view.frame = CGRect(origin: .zero, size: self.pageSize)
                host.view.backgroundColor = .white
                host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true)
            }
        }
    }
}
