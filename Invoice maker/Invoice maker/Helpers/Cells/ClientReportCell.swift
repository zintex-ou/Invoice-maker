import SwiftUI

struct ClientReportCell: ButtonStyle {
    var model: ClientInvoiceReport

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(model.name)
                    .font(.sans(style: .semiBold, size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)

                Text("\(model.invoiceCount) invoices")
                    .font(.sans(style: .regular, size: 12))
                    .foregroundStyle(configuration.isPressed ? .black767676.opacity(0.5) : .black767676)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Circle()
                        .fill(.green69EB89)
                        .frame(width: 8, height: 8)
                    
                    Text("\(model.currency) \(String(format: "%.2f", model.paidAmount))")
                        .font(.sans(style: .semiBold, size: 16))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)
                }

                HStack {
                    Circle()
                        .fill(.violet4663FF)
                        .frame(width: 8, height: 8)
                    
                    Text("\(model.currency) \(String(format: "%.2f", model.unpaidAmount))")
                        .font(.sans(style: .semiBold, size: 16))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
        .padding(.horizontal, 16)
        .background(.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension ButtonStyle where Self == ClientReportCell {
    static func clientReportCell(
        model: ClientInvoiceReport
    ) -> Self {
        ClientReportCell(model: model)
    }
}
