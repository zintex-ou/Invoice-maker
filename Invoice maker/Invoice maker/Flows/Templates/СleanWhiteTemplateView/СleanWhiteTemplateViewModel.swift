import SwiftUI

final class СleanWhiteTemplateViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var customColor: Color = .blueDAE0FF
    @Published var templateModel: InvoiceTemplateModel
    
    init(templateModel: InvoiceTemplateModel) {
        self.templateModel = templateModel
    }
    
    var pages: ([[InvoiceItemRowModel]], Bool) {
        calculatePagination(items: templateModel.items)
    }
    
    var startIndices: [Int] {
        var result: [Int] = []
        var current = 0
        for page in pages.0 {
            result.append(current)
            current += page.count
        }
        return result
    }
    
    func saveAsPDF() {
        let pageSize = CGSize(width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        
        let data = renderer.pdfData { context in
            for index in pages.0.indices {
                context.beginPage()
                
                let view: AnyView = {
                    if index == 0 {
                        return AnyView(
                            СleanWhiteTemplateFirstPageView(
                                templateModel: .init(
                                    header: templateModel.header,
                                    summary: templateModel.summary,
                                    items: pages.0[index]
                                ),
                                customColor: .constant(customColor),
                                isWithSummary: pages.1
                            )
                            .frame(width: pageSize.width,
                                   height: pageSize.height,
                                   alignment: .top)
                        )
                    } else if index == pages.0.count - 1 {
                        return AnyView(
                            СleanWhiteTemplateLastPageView(
                                templateModel: .init(
                                    header: templateModel.header,
                                    summary: templateModel.summary,
                                    items: pages.0[index]
                                ),
                                customColor: .constant(customColor),
                                startIndex: startIndices[currentPage]
                            )
                            .frame(width: pageSize.width,
                                   height: pageSize.height,
                                   alignment: .top)
                        )
                    } else {
                        return AnyView(
                            СleanWhiteTemplateContinuationPageView(items: pages.0[index], startIndex: startIndices[currentPage], customColor: .constant(customColor))
                                .frame(width: pageSize.width,
                                       height: pageSize.height,
                                       alignment: .top)
                        )
                    }
                }()
                
                let hosting = UIHostingController(rootView: view)
                hosting.view.frame = CGRect(origin: .zero, size: pageSize)
                hosting.view.backgroundColor = .white
                
                let window = UIWindow(frame: CGRect(origin: .zero, size: pageSize))
                window.rootViewController = hosting
                window.makeKeyAndVisible()
                
                hosting.view.drawHierarchy(in: CGRect(origin: .zero, size: pageSize), afterScreenUpdates: true)
            }
        }
        
        let filename = "Invoice_\(Int(Date().timeIntervalSince1970)).pdf"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        do {
            try data.write(to: url)
            print("Saved: \(url)")
        } catch {
            print("Error", error)
        }
    }

    private func calculatePagination(
      items: [InvoiceItemRowModel]
    ) -> (pages: [[InvoiceItemRowModel]], isWithSummary: Bool) {
      let rowH: CGFloat = 32
      let firstNormH: CGFloat = 300
      let firstExtH: CGFloat = 430
      let otherH: CGFloat = 700
      let lastH: CGFloat = 700
      let summaryH: CGFloat = 220

      let firstNormLimit = Int(firstNormH / rowH)
      let firstExtLimit = Int(firstExtH  / rowH)
      let otherLimit = Int(otherH     / rowH)
      let lastLimit = Int((lastH - summaryH) / rowH)

      if items.count <= firstNormLimit {
        return ([items], true)
      }

      var pages: [[InvoiceItemRowModel]] = []
      pages.append(Array(items.prefix(firstExtLimit)))
      var remaining = Array(items.dropFirst(firstExtLimit))

      while remaining.count > lastLimit {
        pages.append(Array(remaining.prefix(otherLimit)))
        remaining = Array(remaining.dropFirst(otherLimit))
      }

      pages.append(remaining)

      return (pages, false)
    }
}
