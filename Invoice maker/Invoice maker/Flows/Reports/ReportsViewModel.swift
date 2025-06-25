import SwiftUI
import Combine

final class ReportsViewModel: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var currency: Currency
    @Published var shouldShowCurrencyPicker: Bool = false
    @Published var invoiceReportModel: InvoiceReportModel
    @Published var showCaledar = false
    @Published var clientInvoiceReport: [ClientInvoiceReport] = []
    
    @Published var dates: Set<DateComponents> = {
        let calendar = Calendar.current
        let today = Date()
        let oneMonthAgo = calendar.date(
            byAdding: .month,
            value: -1,
            to: today
        )!
        
        let todayComp = calendar.dateComponents(
            [.year, .month, .day],
            from: today
        )
        let pastComp = calendar.dateComponents(
            [.year, .month, .day],
            from: oneMonthAgo
        )
        return [pastComp, todayComp]
    }()
    @Published var draftDates: Set<DateComponents> = []
    
    @Published var chartSegment: [InvoiceReportChartSegment] = []
    
    let gradientMap: [String: LinearGradient] = [
        "Paid": LinearGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.3, green: 0.85, blue: 0.39), location: 0.00),
                Gradient.Stop(color: Color(red: 0.61, green: 1, blue: 0.67), location: 0.62),
                Gradient.Stop(color: Color(red: 0.24, green: 0.8, blue: 0.34), location: 1.00),
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1)
        ),
        "Unpaid": LinearGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.27, green: 0.39, blue: 1), location: 0.00),
                Gradient.Stop(color: Color(red: 0.62, green: 0.86, blue: 0.98), location: 0.62),
                Gradient.Stop(color: Color(red: 0.73, green: 0.8, blue: 0.98), location: 1.00),
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1)
        )
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    init(currency: Currency = .USD) {
        self.currency = currency
        self.invoiceReportModel = InvoiceReportModel(
            total: 0,
            totalInvoiceCount: 0,
            currency: currency.rawValue,
            paidInvoicesTotal: 0,
            unpaidInvoicesTotal: 0
        )
        
        Task {
            try await fetchInvoicesGroupedByPaidStatus(
                currency: currency,
                from: dates.compactMap { Calendar.current.date(from: $0)
                }.min() ?? .now,
                to: dates.compactMap { Calendar.current.date(from: $0) }.max() ?? .distantFuture)
            
            await setSubscriptions()
        }
    }
    
    private static let fullFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "d MMM yyyy"
        return f
    }()
    
    var formattedDateRange: String {
        let calendar = Calendar.current
        let sortedDates = dates
            .compactMap { calendar.date(from: $0) }
            .sorted()
        
        guard let first = sortedDates.first else {
            return ""
        }
        
        if sortedDates.count == 1 {
            return Self.fullFormatter.string(from: first)
        }
        
        let last = sortedDates.last!
        let startString = Self.fullFormatter.string(from: first)
        let endString   = Self.fullFormatter.string(from: last)
        return "\(startString) – \(endString)"
    }
}

extension ReportsViewModel {
    func onCurrencyButtonTapped() {
        shouldShowCurrencyPicker = true
    }
    
    func commitDraft() {
        guard draftDates.count >= 2 else { return }
        let sorted = draftDates
           .sorted {
             ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture)
           }
         dates = Set(sorted.prefix(2))
     }
}

@MainActor
private extension ReportsViewModel {
    func fetchInvoicesGroupedByPaidStatus(
        currency: Currency,
        from startDate: Date,
        to endDate: Date
    ) async throws {
        let allInvoices = try await CoreDataManager.shared.fetchAllInvoicesInSelectedCurrencyInDateRange(
            withCurrency: currency.rawValue,
            from: startDate,
            to: endDate
        )
        
        let paid = allInvoices.filter { $0.isPaid }
        let unpaid = allInvoices.filter { !$0.isPaid }
        
        let allInvoicesTotal = allInvoices.reduce(0.0) { $0 + $1.total }
        let totalInvoices = allInvoices.count
        let paidTotal = paid.reduce(0.0) { $0 + $1.total }
        let unpaidTotal = unpaid.reduce(0.0) { $0 + $1.total }
        
        let invoicesWithClient = allInvoices.filter { $0.client != nil }
        
        let grouped: [ClientEntity: [InvoiceEntity]] = Dictionary(
            grouping: invoicesWithClient,
            by: { $0.client! }
        )
        
        clientInvoiceReport = grouped.map { client, invoices in
            ClientInvoiceReport(
                id: client.id ?? .init(),
                client: client,
                invoices: invoices,
                name: client.clientName ?? "",
                currency: currency
            )
        }
        .sorted { $0.totalAmount > $1.totalAmount }
        
        invoiceReportModel = InvoiceReportModel(
            total: allInvoicesTotal,
            totalInvoiceCount: totalInvoices,
            currency: currency.rawValue,
            paidInvoicesTotal: paidTotal,
            unpaidInvoicesTotal: unpaidTotal
        )
        
        chartSegment = [.init(label: "Paid", value: invoiceReportModel.paidInvoicesTotal),
                        .init(label: "Unpaid", value: invoiceReportModel.unpaidInvoicesTotal)]
    }
    
    func setSubscriptions() {
        $currency
            .sink { [weak self] currency in
                Task {
                    try await self?.fetchInvoicesGroupedByPaidStatus(
                        currency: currency,
                        from: self?.dates.compactMap { Calendar.current.date(from: $0)
                        }.min() ?? .now,
                        to: self?.dates.compactMap { Calendar.current.date(from: $0) }.max() ?? .distantFuture)
                }
            }
            .store(in: &cancellables)
        
        $dates
            .sink { [weak self] dates in
                Task {
                    try await self?.fetchInvoicesGroupedByPaidStatus(
                        currency: self?.currency ?? .USD,
                        from: dates.compactMap { Calendar.current.date(from: $0)
                        }.min() ?? .now,
                        to: dates.compactMap { Calendar.current.date(from: $0) }.max() ?? .distantFuture)
                }
            }
            .store(in: &cancellables)
    }
}
