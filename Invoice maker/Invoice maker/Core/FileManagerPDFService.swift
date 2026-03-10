import Foundation

final class FileManagerPDFService {
    private let fileManager = FileManager.default

    func savePDF(data: Data, for type: InvoiceType) throws -> URL {
        let path = try generateNewPDFPath(for: type)
        try data.write(to: path, options: .atomic)
        return path
    }
    
    func updatePDF(data: Data, at url: URL, for type: InvoiceType) throws -> URL {
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        
        let newPath = try generateNewPDFPath(for: type)
        try data.write(to: newPath, options: .atomic)
        return newPath
    }
    
    func getAllSavedPDFs(for type: InvoiceType) throws -> [URL] {
        let folderURL = try ensureFolderExists(for: type)
        let contents = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        return contents.filter { $0.pathExtension.lowercased() == "pdf" }
    }
    
    func clearAllPDFs(for type: InvoiceType) throws {
        let folderURL = try ensureFolderExists(for: type)
        let files = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        for file in files where file.pathExtension.lowercased() == "pdf" {
            try fileManager.removeItem(at: file)
        }
    }
    
    func resolvePDFURL(storedURL: URL?, for type: InvoiceType) -> URL? {
        guard let storedURL else { return nil }
        
        if fileManager.fileExists(atPath: storedURL.path) {
            return storedURL
        }
        
        guard !storedURL.lastPathComponent.isEmpty,
              let folderURL = try? ensureFolderExists(for: type) else {
            return nil
        }
        
        let rebuiltURL = folderURL.appendingPathComponent(storedURL.lastPathComponent)
        if fileManager.fileExists(atPath: rebuiltURL.path) {
            return rebuiltURL
        }
        
        return nil
    }
    
    private func generateNewPDFPath(for type: InvoiceType) throws -> URL {
        let folderURL = try ensureFolderExists(for: type)
        let filename = "\(type.rawValue)_\(UUID().uuidString).pdf"
        return folderURL.appendingPathComponent(filename)
    }
    
    private func ensureFolderExists(for type: InvoiceType) throws -> URL {
        let docsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let folderURL = docsURL.appendingPathComponent(type.rawValue)
        
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        return folderURL
    }
}
