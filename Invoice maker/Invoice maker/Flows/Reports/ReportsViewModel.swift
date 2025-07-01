import SwiftUI
import Combine

final class ReportsViewModel: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var currency: Currency
    @Published var shouldShowCurrencyPicker: Bool = false
    @Published var invoiceReportModel: InvoiceReportModel
    @Published var showCalendar = false
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
        "Paid": .greenGradient,
        "Unpaid": .blueGradient
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
        
        setSubscriptions()
    }
    
    private let fullFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "d MMM yyyy"
        return dateFormatter
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
            return fullFormatter.string(from: first)
        }
        
        let last = sortedDates.last!
        let startString = fullFormatter.string(from: first)
        let endString = fullFormatter.string(from: last)
        return "\(startString) – \(endString)"
    }
    
    func chartCenterOverlayTitle() -> String {
        "\(currency.rawValue) \(String(format: "%.2f", invoiceReportModel.total))"
    }
    
    func chartBottomPaidTitle() -> String {
        "\(currency.rawValue) \(String(format: "%.2f", invoiceReportModel.paidInvoicesTotal))"
    }
    
    func chartButtonUnpaidTitle() -> String {
        "\(currency.rawValue) \(String(format: "%.2f", invoiceReportModel.unpaidInvoicesTotal))"
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
    
    func setSubscriptions() {
        Publishers.CombineLatest($currency, $dates)
            .sink { [weak self] currency, dates in
                Task {
                    guard let self else { return }
                    let calendar = Calendar.current
                    let startDate = dates.compactMap { calendar.date(from: $0) }.min() ?? .now
                    let endDate = dates.compactMap { calendar.date(from: $0) }.max() ?? .distantFuture
                    try await self.fetchInvoicesGroupedByPaidStatus(
                        currency: currency,
                        from: startDate,
                        to: endDate
                    )
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func fetchInvoicesGroupedByPaidStatus(
        currency: Currency,
        from startDate: Date,
        to endDate: Date
    ) async throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay: Date = {
            let components = DateComponents(hour: 23, minute: 59, second: 59)
            return calendar.date(byAdding: components, to: calendar.startOfDay(for: endDate)) ?? .now
        }()
        
        let allInvoices = InvoiceDataBaseService.shared.allInvoices
            .filter { invoice in
                guard
                    let invoiceCurrency = invoice.currency,
                    let invoiceDate = invoice.invoiceDate
                else {
                    return false
                }
                
                return invoiceCurrency == currency.rawValue &&
                invoiceDate >= startOfDay &&
                invoiceDate <= endOfDay
            }
        
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
    
    @MainActor
    func refreshReports() async {
        do {
            let calendar = Calendar.current
            let startDate = dates.compactMap { calendar.date(from: $0) }.min() ?? .now
            let endDate = dates.compactMap { calendar.date(from: $0) }.max() ?? .distantFuture
            try await fetchInvoicesGroupedByPaidStatus(currency: currency, from: startDate, to: endDate)
        } catch {
            print("Failed to refresh reports")
        }
    }
}
