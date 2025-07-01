import SwiftUI

struct CustomCalendar: View {
    @Environment(\.calendar) var calendar
    @Binding var range: ClosedRange<Date>?

    var body: some View {
        VStack(spacing: 50) {
            MultiDatePicker("Select dates", selection: bindingForMultiDatePicker)
                .frame(height: 350)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 6)
    }

    private var bindingForMultiDatePicker: Binding<Set<DateComponents>> {
        Binding<Set<DateComponents>>(
            get: {
                guard let range else { return [] }
                return Set(generateDateComponentsRange(from: range))
            },
            set: { newValue in
                let datesArray = newValue
                    .compactMap { calendar.date(from: $0) }
                    .sorted()

                if datesArray.isEmpty {
                    range = nil

                } else if datesArray.count == 1 {
                    let date = datesArray.first!
                    range = date...date

                } else if datesArray.count == 2 {
                    let first = datesArray.first!
                    let last = datesArray.last!
                    range = first...last

                } else if let range = range {
                    let datesSet = Set(generateDateComponentsRange(from: range))
                    let tapped = newValue.subtracting(datesSet)
                    if let tappedDate = tapped.first.flatMap({ calendar.date(from: $0) }) {
                        self.range = tappedDate...tappedDate
                    } else {
                        self.range = nil
                    }
                } else {
                    if let firstDate = datesArray.first {
                        range = firstDate...firstDate
                    }
                }
            }
        )
    }
    
    private func generateDateComponentsRange(from range: ClosedRange<Date>) -> [DateComponents] {
        var componentsArray: [DateComponents] = []
        var currentDate = calendar.startOfDay(for: range.lowerBound)

        while currentDate <= range.upperBound {
            componentsArray.append(calendar.dateComponents([.year, .month, .day], from: currentDate))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return componentsArray
    }
}
