import SwiftUI

struct SegmentedControl<Segment: SegmentedItemProtocol>: View {
    @Binding var selection: Segment
    let segments: [Segment]
    let controlHeight: CGFloat = 48

    var body: some View {
        GeometryReader { geo in
            let controlWidth = geo.size.width

            let segmentsCount = CGFloat(segments.count)
            let segmentWidth = controlWidth / segmentsCount

            let index = CGFloat(segments.firstIndex(of: selection) ?? 0)
            let offsetX = -controlWidth / 2 + segmentWidth / 2 + segmentWidth * index

            ZStack {
                Capsule()
                    .foregroundStyle(.grayF5F5F5)
                    .frame(height: controlHeight)

                Capsule()
                    .foregroundStyle(.violet4663FF)
                    .frame(maxWidth: segmentWidth - 4, maxHeight: controlHeight - 4)
                    .offset(x: offsetX)
                    .animation(.easeInOut(duration: 0.3), value: selection)

                HStack(spacing: 0) {
                    ForEach(segments, id: \.self) { segment in
                        Button {
                            withAnimation { selection = segment }
                        } label: {
                            Text(segment.title)
                                .font(
                                    .sans(
                                        style: selection == segment ? .semiBold : .regular,
                                        size: 16
                                    )
                                )
                                .foregroundStyle(selection == segment ? .white : .black)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .frame(height: controlHeight)
            }
        }
        .frame(height: controlHeight)
    }
}

struct SegmentedControl_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var invoiceSelection: SegmentInvoiceType = .all
        @State var offerSelection: SegmentOfferType = .items

        var body: some View {
            VStack(spacing: 20) {
                SegmentedControl(
                    selection: $invoiceSelection,
                    segments: SegmentInvoiceType.allCases
                )

                SegmentedControl(
                    selection: $offerSelection,
                    segments: SegmentOfferType.allCases
                )
            }
            .padding(16)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
