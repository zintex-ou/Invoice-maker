import SwiftUI
import Charts

struct ReportsView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var viewModel = ReportsViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    filterView
                    
                    chart
                    
                    VStack(spacing: 8) {
                        ForEach(viewModel.clientInvoiceReport, id: \.id) { report in
                            Button("") {
                                coordinator.pushTo(id: ClientInvoicesListView.navigationID) {
                                    ClientInvoicesListView(viewModel: .init(report: report))
                                }
                            }
                            .buttonStyle(
                                .clientReportCell(model: report)
                            )
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
            .scrollIndicators(.hidden)
            .sheet(isPresented: $viewModel.shouldShowCurrencyPicker) {
                CurrencyPickerView(currency: $viewModel.currency)
                    .presentationDetents([.large])
            }
            .overlay(alignment: .center) {
                if viewModel.showCalendar {
                    ZStack {
                        Color.black767676.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    viewModel.showCalendar = false
                                }
                            }
                        CustomCalendar(range: $viewModel.draftDates)
                            .onAppear {
                                viewModel.draftDates = viewModel.dateRange
                            }
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .onChange(of: viewModel.showCalendar) { isShowing in
                guard !isShowing else { return }
                viewModel.commitDraft()
            }
            .task {
                await viewModel.refreshReports()
            }
            
            ListTopShadow()
        }
    }
    
    private var filterView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Time period")
                .font(.sans(style: .regular, size: 12))
                .foregroundColor(.black767676)
                .padding(.horizontal, 16)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.grayF5F5F5)
                    .frame(height: 48)
                
                Text(viewModel.formattedDateRange)
                    .font(.sans(style: .regular, size: 16))
                    .foregroundStyle(.black)
                    .tint(.black)
                    .padding(.horizontal, 16)
            }
            .onTapGesture {
                withAnimation {
                    viewModel.showCalendar = true
                }
            }
            
            Button(viewModel.currency.rawValue) {
                viewModel.onCurrencyButtonTapped()
            }
            .buttonStyle(.disclosure(title: "Currency"))
            .padding(.top, 22)
        }
        .padding(.top, 24)
    }
    
    private var chart: some View {
        VStack(spacing: 12) {
            ZStack {
                if #available(iOS 17.0, *) {
                    VStack {
                        Chart {
                            let safeSegments = viewModel.chartSegment
                            
                            ForEach(safeSegments, id: \.self) { item in
                                SectorMark(
                                    angle: .value("Total", item.value),
                                    innerRadius: .ratio(0.8),
                                    angularInset: 4
                                )
                                .cornerRadius(8)
                                .foregroundStyle(
                                    viewModel.gradientMap[
                                        item.label,
                                        default: LinearGradient(
                                            colors: [.gray],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    ]
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 330)
                    }
                    .chartOverlay { proxy in
                        chartCenterOverlay
                            .frame(width: proxy.plotSize.width, height: proxy.plotSize.height)
                            .position(x: proxy.plotSize.width / 2, y: proxy.plotSize.height / 2)
                    }
                    .clipped()
                } else {
                    let values = viewModel.chartSegment.compactMap { $0.value }
                    DonutChartView(values: values)
                        .padding(.horizontal, 47)
                        .overlay {
                            chartCenterOverlay
                        }
                }
            }
            
            chartBottomView
                .padding(.top, 12)
        }
        .padding(.vertical, 24)
    }
    
    private var chartCenterOverlay: some View {
        GeometryReader { geometry in
            VStack {
                Text(viewModel.chartCenterOverlayTitle())
                    .font(.sans(style: .semiBold, size: 26))
                    .foregroundStyle(.black)
                    .frame(maxWidth: geometry.size.width * 0.6)
                
                Text("\(viewModel.invoiceReportModel.totalInvoiceCount) invoices")
                    .font(.sans(style: .regular, size: 16))
                    .foregroundStyle(.black767676)
                    .frame(maxWidth: geometry.size.width * 0.6)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(.center)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private var chartBottomView: some View {
        HStack(spacing: 30) {
            VStack {
                HStack(spacing: 2) {
                    Circle()
                        .fill(.green69EB89)
                        .frame(width: 8, height: 8)
                    
                    Text("Paid")
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(.black)
                }
                
                Text(viewModel.chartBottomPaidTitle())
                    .lineLimit(1)
            }
            
            VStack {
                HStack(spacing: 2) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                    
                    Text("Unpaid")
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(.black)
                }
                
                Text(viewModel.chartButtonUnpaidTitle())
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    ReportsView()
}
