import SwiftUI

final class CorporateTemplateViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var customColor = Color.blueDAE0FF
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
