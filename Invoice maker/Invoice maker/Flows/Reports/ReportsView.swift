import SwiftUI
import Charts

struct ReportsView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var viewModel = ReportsViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
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
                .padding(.bottom, 68)
            }
            .padding(.horizontal, 16)
            .scrollIndicators(.hidden)
            .sheet(isPresented: $viewModel.shouldShowCurrencyPicker) {
                CurrencyPickerView(currency: $viewModel.currency)
                    .presentationDetents([.large])
            }
            .overlay {
                if viewModel.showCaledar {
                    ZStack {
                        Color
                            .black767676.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    viewModel.showCaledar = false
                                }
                            }
                        
                        calendarView
                            .onAppear {
                                viewModel.draftDates = viewModel.dates
                            }
                    }
                }
            }
            .onChange(of: viewModel.showCaledar) { isShowing in
                guard !isShowing else { return }
                viewModel.commitDraft()
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
                    viewModel.showCaledar = true
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
                            if viewModel.chartSegment.reduce(0, { $0 + $1.value }) == 0 {
                                SectorMark(
                                    angle: .value("Total", 100),
                                    innerRadius: .ratio(0.7),
                                    angularInset: 4
                                )
                                .cornerRadius(8)
                                .foregroundStyle(.grayF5F5F5)
                            } else {
                                ForEach(viewModel.chartSegment, id: \.id) { item in
                                    SectorMark(
                                        angle: .value("Total", item.value),
                                        innerRadius: .ratio(0.7),
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
                        }
                        .frame(maxWidth: .infinity, minHeight: 330)
                    }
                } else {
                    let values = viewModel.chartSegment.compactMap { $0.value }
                    DonutChartView(values: values)
                        .padding(.horizontal, 47)
                }
                
                chartCenterOverlay
            }
            
            chartBottomView
                .padding(.top, 12)
        }
        .padding(.vertical, 24)
    }
    
    private var chartCenterOverlay: some View {
        VStack {
            Text(viewModel.chartCenterOverlayTitle())
                .font(.sans(style: .semiBold, size: 26))
                .foregroundStyle(.black)
            
            Text("\(viewModel.invoiceReportModel.totalInvoiceCount) invoices")
                .font(.sans(style: .regular, size: 16))
                .foregroundStyle(.black767676)
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
            }
        }
    }
    
    @ViewBuilder
    private var calendarView: some View {
        if #available(iOS 17.0, *) {
            VStack(spacing: 7) {
                MultiDatePicker("Time period", selection: $viewModel.draftDates)
                    .datePickerStyle(.graphical)
                    .padding(.bottom, 2)
                    .onChange(of: viewModel.draftDates) { new in
                        if new.count > 2 {
                            let sorted = new.sorted {
                                ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture)
                            }
                            viewModel.draftDates = Set(sorted.prefix(2))
                        }
                    }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(height: 300)
            .padding(.horizontal, 6)
        } else {
            CustomCalendarWithTimePicker(dates: $viewModel.draftDates)
        }
    }
}

#Preview {
    ReportsView()
}
