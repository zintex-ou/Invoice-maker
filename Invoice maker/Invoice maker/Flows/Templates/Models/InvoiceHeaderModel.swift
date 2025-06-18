import Foundation

struct InvoiceHeaderModel {
    var logo: Data?
    var businessProfile: ContactInfo
    var billTo: ContactInfo
    var invoiceInfo: InvoiceMeta
}

struct ContactInfo {
    var name: String
    var email: String
    var phone: String
    var address: String
}

struct InvoiceMeta {
    var number: String
    var date: String
    var dueDate: String
}
