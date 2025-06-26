import SwiftUI

struct CustomCalendarWithTimePicker: View {
    @Binding var dates: Set<DateComponents>
    
    private let calendar = Calendar.current
    
    @State private var displayedMonth: Date = {
          let now = Date()
          let comps = Calendar.current.dateComponents([.year, .month], from: now)
          return Calendar.current.date(from: comps)!
      }()
    
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstDay = calendar.date(
                  from: calendar.dateComponents([.year, .month], from: displayedMonth))
        else { return [] }
        return range.map { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            header
            
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 8) {
                ForEach(["SUN","MON","TUE","WED","THU","FRI","SAT"], id: \.self) { day in
                    Text(day)
                        .font(.sans(style: .semiBold, size: 13))
                        .foregroundColor(.gray.opacity(0.3))
                }
                
                ForEach(daysInMonth, id: \.self) { date in
                    let comp = calendar.dateComponents([.year, .month, .day], from: date)
                    let isSelected = dates.contains(comp)
                    let isToday    = calendar.isDateInToday(date)
                    
                    Text("\(calendar.component(.day, from: date))")
                        .fontWeight(isSelected ? .medium : .regular)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                              .fill(isSelected
                                    ? Color.blue.opacity(0.2)
                                    : Color.clear)
                        )
                        .foregroundColor(
                            isSelected
                              ? Color.blue
                              : (isToday ? Color.blue : .primary)
                        )
                        .onTapGesture { toggle(date: date) }
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .padding(.horizontal, 6)
    }
    
    private var header: some View {
        HStack {
            Button { changeMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthYearString(from: displayedMonth))
                .font(.headline)
            Spacer()
            Button { changeMonth(by: +1) } label: {
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private func changeMonth(by offset: Int) {
        if let m = calendar.date(byAdding: .month, value: offset, to: displayedMonth) {
            displayedMonth = m
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date)
    }
    
    private func toggle(date: Date) {
        let comp = calendar.dateComponents([.year, .month, .day], from: date)
        if dates.contains(comp) {
            dates.remove(comp)
        } else if dates.count < 2 {
            dates.insert(comp)
        }
    }
}
