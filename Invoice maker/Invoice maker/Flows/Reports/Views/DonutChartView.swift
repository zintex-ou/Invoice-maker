import SwiftUI
import Foundation

struct DonutChartView: View {
    let values: [Double]
    private let gradients: [AngularGradient] = [
        AngularGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.3, green: 0.85, blue: 0.39), location: 0.00),
                Gradient.Stop(color: Color(red: 0.61, green: 1, blue: 0.67), location: 0.62),
                Gradient.Stop(color: Color(red: 0.24, green: 0.8, blue: 0.34), location: 1.00),
            ],
            center: UnitPoint(x: 1, y: 0.1)
        ),
        AngularGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.27, green: 0.39, blue: 1), location: 0.00),
                Gradient.Stop(color: Color(red: 0.62, green: 0.86, blue: 0.98), location: 0.62),
                Gradient.Stop(color: Color(red: 0.73, green: 0.8, blue: 0.98), location: 1.00),
            ],
            center: UnitPoint(x: 1, y: 0.1)
        )
    ]
    private let segments: [(from: Double, to: Double)]
    
    init(values: [Double]) {
        self.values = values
        
        let temporaryGap = 0.05
        
        let total = values.reduce(0, +)
        var start: Double = 0
        
        self.segments = values.map { value in
            let frac = value / total
            let from = start + temporaryGap/2
            let to = start + frac - temporaryGap/2
            start += frac
            return (from: from, to: to)
        }
    }
    
    var body: some View {
        ZStack {
            if values.reduce(0.0, +) == 0 {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(
                        Color.grayF5F5F5,
                        style: StrokeStyle(lineWidth: 35, lineCap: .butt)
                    )
                    .rotationEffect(.degrees(-90))
            } else {
                ForEach(segments.indices, id: \.self) { index in
                    Circle()
                        .trim(from: segments[index].from, to: segments[index].to)
                        .stroke(
                            gradients[index],
                            style: StrokeStyle(
                                lineWidth: 35,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                }
            }
        }
    }
}
