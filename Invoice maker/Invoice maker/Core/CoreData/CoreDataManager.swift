import CoreData

final class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "CoreDataModel")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error)")
            }
        }
    }
    
    private var viewContext: NSManagedObjectContext { container.viewContext }
}

// MARK: - Business Profile
extension CoreDataManager {
    func fetchBusinessProfile() async throws -> BusinessProfileEntity? {
        try await viewContext.perform {
            let request: NSFetchRequest<BusinessProfileEntity> = BusinessProfileEntity.fetchRequest()
            request.fetchLimit = 1
            return try self.viewContext.fetch(request).first
        }
    }
    
    @discardableResult
    func createBusinessProfile(input: BusinessProfileInput) async throws -> BusinessProfileEntity {
        try await viewContext.perform {
            let businessProfile = BusinessProfileEntity(context: self.viewContext)
            businessProfile.ownerName = input.ownerName
            businessProfile.email = input.email
            businessProfile.phoneNumber = input.phoneNumber
            businessProfile.country = input.country
            businessProfile.city = input.city
            businessProfile.street = input.street
            businessProfile.apartment = input.apartment
            businessProfile.postalCode = input.postalCode
            businessProfile.image = input.imageData
            try self.viewContext.save()
            return businessProfile
        }
    }
    
    func updateBusinessProfile(input: BusinessProfileInput) async throws {
        guard let profile = try await fetchBusinessProfile() else {
            throw NSError(domain: "BusinessProfileError", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Business profile not found."
            ])
        }
        
        try await viewContext.perform {
            guard let businessProfile = try? self.viewContext.existingObject(with: profile.objectID) as? BusinessProfileEntity else {
                throw NSError(domain: "BusinessProfileError", code: 500, userInfo: [
                    NSLocalizedDescriptionKey: "Failed to retrieve existing BusinessProfileEntity."
                ])
            }
            
            businessProfile.ownerName = input.ownerName
            businessProfile.email = input.email
            businessProfile.phoneNumber = input.phoneNumber
            businessProfile.country = input.country
            businessProfile.city = input.city
            businessProfile.street = input.street
            businessProfile.apartment = input.apartment
            businessProfile.postalCode = input.postalCode
            businessProfile.image = input.imageData
            
            try self.viewContext.save()
        }
    }

}

// MARK: - Client
extension CoreDataManager {
    func fetchClients() async throws -> [ClientEntity] {
        try await viewContext.perform {
            let request: NSFetchRequest<ClientEntity> = ClientEntity.fetchRequest()
            return try self.viewContext.fetch(request)
        }
    }
    
    @discardableResult
    func createClient(input: ClientInput) async throws -> ClientEntity {
        try await viewContext.perform {
            let client = ClientEntity(context: self.viewContext)
            client.id = input.id
            client.clientName = input.clientName
            client.email = input.email
            client.phoneNumber = input.phoneNumber
            client.fax = input.fax
            client.country = input.country
            client.city = input.city
            client.street = input.street
            client.apartment = input.apartment
            client.postalCode = input.postalCode
            try self.viewContext.save()
            return client
        }
    }
    
    @discardableResult
    func updateClient(_ client: ClientEntity,
                      input: ClientInput) async throws -> ClientEntity {
        try await viewContext.perform {
            let client = try self.viewContext.existingObject(with: client.objectID) as! ClientEntity
            client.clientName = input.clientName
            client.email = input.email
            client.phoneNumber = input.phoneNumber
            client.fax = input.fax
            client.country = input.country
            client.city = input.city
            client.street = input.street
            client.apartment = input.apartment
            client.postalCode = input.postalCode
            try self.viewContext.save()
            return client
        }
    }
    
    func deleteClient(_ client: ClientEntity) async throws {
        try await viewContext.perform {
            let toDelete = try self.viewContext.existingObject(with: client.objectID)
            self.viewContext.delete(toDelete)
            try self.viewContext.save()
        }
    }
}

// MARK: - Item/Service
extension CoreDataManager {
    func fetchItems() async throws -> [ItemServiceEntity] {
        try await self.viewContext.perform {
            let request: NSFetchRequest<ItemServiceEntity> = ItemServiceEntity.fetchRequest()
            return try self.viewContext.fetch(request)
        }
    }
    
    @discardableResult
    func createItemOrService(input: ItemServiceInput) async throws -> ItemServiceEntity {
        try await viewContext.perform {
            let item = ItemServiceEntity(context: self.viewContext)
            item.id = input.id
            item.isItem = input.isItem
            item.name = input.name
            item.price = input.price
            item.quantity = input.quantity
            item.discountType = input.discountType.rawValue
            item.discount = input.discount
            item.tax = input.tax
            item.currency = input.currency.rawValue
            item.total = input.total
            try self.viewContext.save()
            return item
        }
    }
    
    @discardableResult
    func updateItemOrService(_ item: ItemServiceEntity,
                             input: ItemServiceInput) async throws -> ItemServiceEntity {
        try await viewContext.perform {
            let item = try self.viewContext.existingObject(with: item.objectID) as! ItemServiceEntity
            item.isItem = input.isItem
            item.name = input.name
            item.price = input.price
            item.quantity = input.quantity
            item.discountType = input.discountType.rawValue
            item.discount = input.discount
            item.tax = input.tax
            item.currency = input.currency.rawValue
            item.total = input.total
            try self.viewContext.save()
            return item
        }
    }
    
    func deleteItemOrService(_ item: ItemServiceEntity) async throws {
        try await viewContext.perform {
            let toDelete = try self.viewContext.existingObject(with: item.objectID)
            self.viewContext.delete(toDelete)
            try self.viewContext.save()
        }
    }
}

// MARK: - Invoice

extension CoreDataManager {
    func fetchAllInvoices() async throws -> [InvoiceEntity] {
        try await viewContext.perform {
            let request: NSFetchRequest<InvoiceEntity> = InvoiceEntity.fetchRequest()
            return try self.viewContext.fetch(request)
        }
    }
    
    func fetchAllInvoicesInSelectedCurrencyInDateRange(
        withCurrency currency: String,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [InvoiceEntity] {
        try await viewContext.perform {
            let request: NSFetchRequest<InvoiceEntity> = InvoiceEntity.fetchRequest()
            
            let currencyPredicate = NSPredicate(format: "currency == %@", currency)
            let datePredicate = NSPredicate(format: "invoiceDate >= %@ AND invoiceDate <= %@", startDate as NSDate, endDate as NSDate)
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [currencyPredicate, datePredicate])
            
            return try self.viewContext.fetch(request)
        }
    }

    
    func createInvoice(input: InvoiceInput) async throws -> InvoiceEntity {
        try await viewContext.perform {
            let request: NSFetchRequest<ClientEntity> = ClientEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id as CVarArg)
            request.fetchLimit = 1
            
            let invoice = InvoiceEntity(context: self.viewContext)
            invoice.id = input.id
            invoice.invoiceNumber = input.number
            invoice.invoiceDate = input.invoiceDate
            invoice.dueDate = input.dueDate
            invoice.currency = input.currency
            invoice.discount = input.discount
            invoice.tax = input.tax
            invoice.isPaid = input.isPaid
            invoice.client = input.client
            invoice.total = input.total
            invoice.pdfFilePath = input.pdfFilePath.absoluteString
            invoice.type = input.type.rawValue
            
            for itemInput in input.itemOrServices {
                let item = ItemServiceEntity(context: self.viewContext)
                item.id = itemInput.id
                item.isItem = itemInput.isItem
                item.name = itemInput.name
                item.price = itemInput.price
                item.quantity = itemInput.quantity
                item.discountType = itemInput.discountType
                item.discount = itemInput.discount
                item.tax = itemInput.tax
                
                invoice.addToItemService(item)
            }
            
            try self.viewContext.save()
            return invoice
        }
    }
    
    @discardableResult
    func updateInvoice(_ invoice: InvoiceEntity,
                       input: InvoiceInput) async throws -> InvoiceEntity {
        try await viewContext.perform {
            let invoice = try self.viewContext.existingObject(with: invoice.objectID) as! InvoiceEntity
            invoice.invoiceNumber = input.number
            invoice.invoiceDate = input.invoiceDate
            invoice.dueDate = input.dueDate
            invoice.currency = input.currency
            invoice.discount = input.discount
            invoice.tax = input.tax
            invoice.isPaid = input.isPaid
            invoice.total = input.total
            invoice.pdfFilePath = input.pdfFilePath.absoluteString
            invoice.type = input.type.rawValue
            
            let request: NSFetchRequest<ClientEntity> = ClientEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id as CVarArg)
            request.fetchLimit = 1
            
            invoice.client = input.client
            
            for itemInput in input.itemOrServices {
                let item = ItemServiceEntity(context: self.viewContext)
                item.id = itemInput.id
                item.isItem = itemInput.isItem
                item.name = itemInput.name
                item.price = itemInput.price
                item.quantity = itemInput.quantity
                item.discountType = itemInput.discountType
                item.discount = itemInput.discount
                item.tax = itemInput.tax
                
                invoice.addToItemService(item)
            }
            
            try self.viewContext.save()
            return invoice
        }
    }
    
    func deleteInvoice(_ invoice: InvoiceEntity) async throws {
        try await viewContext.perform {
            let toDelete = try self.viewContext.existingObject(with: invoice.objectID)
            self.viewContext.delete(toDelete)
            try self.viewContext.save()
        }
    }
    
    func deleteInvoice(byID id: UUID) async throws {
        try await viewContext.perform {
            let req: NSFetchRequest<InvoiceEntity> = InvoiceEntity.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            req.fetchLimit = 1

            if let toDelete = try self.viewContext.fetch(req).first {
                self.viewContext.delete(toDelete)
                try self.viewContext.save()
            }
        }
    }
}
