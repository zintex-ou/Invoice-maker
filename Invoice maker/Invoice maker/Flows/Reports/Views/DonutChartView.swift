import SwiftUI
import Foundation

struct DonutChartView: View {
    let values: [Double]
    private let gradients: [AngularGradient] = [
        .greenGradient,
        .blueGradient
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
