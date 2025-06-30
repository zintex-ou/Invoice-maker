import SwiftUI
import PDFKit

struct PDFPageView: View {
    @State private var image: UIImage? = nil

    private let url: URL
    private let pageNumber: Int

    init(url: URL, pageNumber: Int) {
        self.url = url
        self.pageNumber = pageNumber
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 6.4))
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 6.4)
                        .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        )
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 6.4)
                    .inset(by: 0.35)
                    .stroke(Color(red: 0.82, green: 0.82, blue: 0.82), lineWidth: 0.7)
            )
            .onAppear {
                if image == nil {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let thumbnail = getPageThumbnail(for: geometry.size)
                        DispatchQueue.main.async {
                            withAnimation {
                                self.image = thumbnail
                            }
                        }
                    }
                }
            }
        }
    }

    private func getPageThumbnail(for size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        guard FileManager.default.fileExists(atPath: url.path),
              let document = PDFDocument(url: url),
              let page = document.page(at: pageNumber) else {
            return nil
        }

        let pageRect = page.bounds(for: .mediaBox)
        let pdfScale = min(size.width / pageRect.width, size.height / pageRect.height)

        let scaledSize = CGSize(width: pageRect.width * pdfScale, height: pageRect.height * pdfScale)

        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = scale

        let renderer = UIGraphicsImageRenderer(size: scaledSize, format: rendererFormat)

        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: .zero, size: scaledSize))

            ctx.cgContext.saveGState()
            ctx.cgContext.translateBy(x: 0, y: scaledSize.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.scaleBy(x: pdfScale, y: pdfScale)
            page.draw(with: .mediaBox, to: ctx.cgContext)
            ctx.cgContext.restoreGState()
        }

        return img
    }
}
