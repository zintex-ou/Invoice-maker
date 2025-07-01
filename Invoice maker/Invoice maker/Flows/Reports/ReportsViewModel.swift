import SwiftUI
import Combine

@MainActor
final class ReportsViewModel: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var currency: Currency
    @Published var shouldShowCurrencyPicker: Bool = false
    @Published var invoiceReportModel: InvoiceReportModel
    @Published var clientInvoiceReport: [ClientInvoiceReport] = []
    
    @Published var dateRange: ClosedRange<Date> = {
        let today = Calendar.current.startOfDay(for: Date())
        return today...today
    }()
    
    @Published var chartSegment: [InvoiceReportChartSegment] = []
    
    let gradientMap: [String: LinearGradient] = [
        "Paid": .greenGradient,
        "Unpaid": .blueGradient,
        "No Data": LinearGradient(
            colors: [.grayF5F5F5],
            startPoint: .top,
            endPoint: .bottom
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
        
        setSubscriptions()
    }
    
    private let fullFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "d MMM yyyy"
        return dateFormatter
    }()
    
    var formattedDateRange: String {
        let startString = fullFormatter.string(from: dateRange.lowerBound)
        let endString = fullFormatter.string(from: dateRange.upperBound)
        
        if Calendar.current.isDate(dateRange.lowerBound, inSameDayAs: dateRange.upperBound) {
            return startString
        } else {
            return "\(startString) – \(endString)"
        }
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
    
    func showCalendar() {
        NotificationService.shared.post(event: .showCalendar, object: dateRange)
    }
}

extension ReportsViewModel {
    func onCurrencyButtonTapped() {
        shouldShowCurrencyPicker = true
    }
    
    func setSubscriptions() {
        Publishers.CombineLatest($currency, $dateRange)
            .dropFirst()
            .sink { [weak self] currency, dates in
                Task {
                    guard let self else { return }
                    let startDate = self.dateRange.lowerBound
                    let endDate = self.dateRange.upperBound
                    try await self.fetchInvoicesGroupedByPaidStatus(
                        currency: currency,
                        from: startDate,
                        to: endDate
                    )
                }
            }
            .store(in: &cancellables)
        
        NotificationService.shared.observe(event: .hideCalendar) { [weak self] object in
            if let object = object as? ClosedRange<Date> {
                self?.dateRange = object
            }
        }
    }

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
                    let invoiceDate = invoice.dueDate
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
        
        let grouped = Dictionary(grouping: allInvoices.filter { $0.client != nil }, by: { $0.client! })
        
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
        
        if allInvoicesTotal == 0 {
            chartSegment = [.init(label: "No Data", value: 100),
                            .init(label: "No Data", value: 100)]
        } else {
            chartSegment = [.init(label: "Paid", value: paidTotal),
                            .init(label: "Unpaid", value: unpaidTotal)]
        }
    }
    
    @MainActor
    func refreshReports() async {
        do {
            let startDate = dateRange.lowerBound
            let endDate = dateRange.upperBound
            try await fetchInvoicesGroupedByPaidStatus(currency: currency, from: startDate, to: endDate)
        } catch {
            print("Failed to refresh reports")
        }
    }
}
