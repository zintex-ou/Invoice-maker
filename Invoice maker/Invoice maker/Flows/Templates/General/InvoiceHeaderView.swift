import SwiftUI

struct InvoiceHeaderView: View {
    var model: InvoiceHeaderModel
    var titleColor: Color
    var type: TemplateType
    
    var body: some View {
        HStack(alignment: .top, spacing: 22) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Business profile:")
                    .font(.sans(style: .semiBold, size: 12))
                    .foregroundStyle(titleColor)
                    .padding(.bottom, 4)
                
                Text(model.businessProfile.name)
                    .font(.sans(style: .regular, size: 8))
                    .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.65))
                
                labeledField("Email", value: model.businessProfile.email)
                
                labeledField("Phone", value: model.businessProfile.phone)
                
                labeledField("Adress", value: model.businessProfile.address)
            }
            
            if type == .cleanWhite || type == .corporate || type == .minimal {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Bill to:")
                    .font(.sans(style: .semiBold, size: 12))
                    .foregroundStyle(titleColor)
                    .padding(.bottom, 4)
                
                Text(model.billTo.name)
                    .font(.sans(style: .regular, size: 8))
                    .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.65))
                
                labeledField("Email", value: model.billTo.email)
                
                labeledField("Phone", value: model.billTo.phone)
                
                labeledField("Adress", value: model.billTo.address)
            }
            
            if type == .cleanWhite || type == .corporate || type == .minimal {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Invoice info:")
                    .font(.sans(style: .semiBold, size: 12))
                    .foregroundStyle(titleColor)
                    .padding(.bottom, 4)
                
                labeledField("Number of invoice:", value: model.invoiceInfo.number)
                
                labeledField("Invoice date:", value: model.invoiceInfo.date)
                
                labeledField("Due date:", value: model.invoiceInfo.dueDate)
            }
            
            if type == .cleanWhite || type == .corporate || type == .minimal {
                Spacer()
            }
        }
    }
    
    private func labeledField(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.sans(style: .bold, size: 8))
                .foregroundStyle(titleColor)
                .lineLimit(1)
            
            Text(value)
                .font(.sans(style: .regular, size: 8))
                .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.65))
                .lineLimit(1)
        }
    }
}
