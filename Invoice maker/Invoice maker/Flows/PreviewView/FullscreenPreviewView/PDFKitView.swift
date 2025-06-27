import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let url: URL
    let withScroll: Bool
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.scaleFactor = 0.6
        pdfView.isUserInteractionEnabled = withScroll
        pdfView.backgroundColor = .grayF5F5F5
        pdfView.displayMode = .singlePageContinuous//withScroll ? .singlePageContinuous : .singlePage
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
    }
}
