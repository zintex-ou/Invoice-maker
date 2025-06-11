import CoreData

final class CoreDataManager {
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
    
    func createBusinessProfile(input: BusinessProfileInput) async throws -> BusinessProfileEntity {
        try await viewContext.perform {
            let businessProfile = BusinessProfileEntity(context: self.viewContext)
            businessProfile.ownerName = input.ownerName
            businessProfile.email = input.email
            businessProfile.phoneNumber = input.phoneNumber
            businessProfile.currency = input.currency
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
    
    func updateBusinessProfile(_ profile: BusinessProfileEntity,
                               input: BusinessProfileInput) async throws -> BusinessProfileEntity {
        try await viewContext.perform {
            let businessProfile = try self.viewContext.existingObject(with: profile.objectID) as! BusinessProfileEntity
            businessProfile.ownerName = input.ownerName
            businessProfile.email = input.email
            businessProfile.phoneNumber = input.phoneNumber
            businessProfile.currency = input.currency
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
}

// MARK: - Client
extension CoreDataManager {
    func fetchClients() async throws -> [ClientEntity] {
        try await viewContext.perform {
            let request: NSFetchRequest<ClientEntity> = ClientEntity.fetchRequest()
            return try self.viewContext.fetch(request)
        }
    }
    
    func createClient(input: ClientInput) async throws -> ClientEntity {
        try await viewContext.perform {
            let client = ClientEntity(context: self.viewContext)
            client.id = UUID()
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
    
    func createItemOrService(input: ItemServiceInput) async throws -> ItemServiceEntity {
        try await viewContext.perform {
            let item = ItemServiceEntity(context: self.viewContext)
            item.id = UUID()
            item.isItem = input.isItem
            item.name = input.name
            item.itemDescription = input.description
            item.price = input.price
            item.quantity = input.quantity
            item.tax = input.tax
            
            try self.viewContext.save()
            return item
        }
    }
    
    func updateItemOrService(_ item: ItemServiceEntity,
                             input: ItemServiceInput) async throws -> ItemServiceEntity {
        try await viewContext.perform {
            let item = try self.viewContext.existingObject(with: item.objectID) as! ItemServiceEntity
            item.isItem = input.isItem
            item.name = input.name
            item.itemDescription = input.description
            item.price = input.price
            item.quantity = input.quantity
            item.tax = input.tax
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
    
    func createInvoice(input: InvoiceInput) async throws -> InvoiceEntity {
        try await viewContext.perform {
            let client = try self.viewContext.existingObject(with: input.client.objectID) as! ClientEntity
            let invoice = InvoiceEntity(context: self.viewContext)
            invoice.id = UUID()
            invoice.invoiceNumber = input.number
            invoice.invoiceDate = input.invoiceDate
            invoice.dueDate = input.dueDate
            invoice.currency = input.currency
            invoice.discount = input.discount
            invoice.tax = input.tax
            invoice.isPaid = input.isPaid
            invoice.client = client
            
            for itemInput in input.itemOrServices {
                let item = ItemServiceEntity(context: self.viewContext)
                item.id = UUID()
                item.isItem = itemInput.isItem
                item.name = itemInput.name
                item.itemDescription = itemInput.description
                item.price = itemInput.price
                item.quantity = itemInput.quantity
                item.tax = itemInput.tax
                
                invoice.addToItemService(item)
            }
            
            try self.viewContext.save()
            return invoice
        }
    }
    
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
            
            let client = try self.viewContext.existingObject(with: input.client.objectID) as! ClientEntity
            invoice.client        = client
            
            for itemInput in input.itemOrServices {
                let item = ItemServiceEntity(context: self.viewContext)
                item.id = UUID()
                item.isItem = itemInput.isItem
                item.name = itemInput.name
                item.itemDescription = itemInput.description
                item.price = itemInput.price
                item.quantity = itemInput.quantity
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
}
