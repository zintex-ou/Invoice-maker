import Foundation

extension InvoiceEntity {
    func toTemplateModel() async -> InvoiceTemplateModel {
        let businessProfile: BusinessProfileEntity?
        do {
            businessProfile = try await CoreDataManager.shared.fetchBusinessProfile()
        } catch {
            businessProfile = nil
        }

        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
        }()

        let contactInfo = ContactInfo(
            name: businessProfile?.ownerName    ?? "",
            email: businessProfile?.email        ?? "",
            phone: businessProfile?.phoneNumber  ?? "",
            address: [
                businessProfile?.street,
                businessProfile?.city,
                businessProfile?.postalCode
            ]
            .compactMap { $0 }
            .joined(separator: ", ")
        )

        let clientEntity = client
        let billInfo = ContactInfo(
            name: clientEntity?.clientName   ?? "",
            email: clientEntity?.email        ?? "",
            phone: clientEntity?.phoneNumber  ?? "",
            address: [
                clientEntity?.street,
                clientEntity?.city,
                clientEntity?.postalCode
            ]
            .compactMap { $0 }
            .joined(separator: ", ")
        )

        let invoiceInfo = InvoiceMeta(
            number: invoiceNumber ?? "",
            date: dateFormatter.string(from: invoiceDate ?? Date()),
            dueDate: dateFormatter.string(from: dueDate ?? Date())
        )
        
        let header = InvoiceHeaderModel(
            businessProfile: contactInfo,
            billTo: billInfo,
            invoiceInfo: invoiceInfo
        )

        let summary = InvoiceSummaryModel(
            currency: Currency(rawValue: currency ?? "") ?? .USD,
            subtotal: total
        )

        let services = (itemService as? Set<ItemServiceEntity>) ?? []
        let items: [InvoiceItemRowModel] = services.map { entity in
            InvoiceItemRowModel(
                name: entity.name ?? "",
                pricePerUnit: Double(entity.price ?? "") ?? 0,
                quantity: Double(entity.quantity ?? "") ?? 0,
                discountPercentage: Double(entity.discount ?? "") ?? 0,
                taxPercentage: Double(entity.tax ?? "") ?? 0
            )
        }

        return InvoiceTemplateModel(
            id: id ?? UUID(),
            header: header,
            summary: summary,
            items: items
        )
    }
}
