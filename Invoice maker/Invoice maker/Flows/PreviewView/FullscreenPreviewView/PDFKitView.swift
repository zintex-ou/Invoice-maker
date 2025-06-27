import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let url: URL
    let withScroll: Bool
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        pdfView.isUserInteractionEnabled = withScroll
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
    }
}
