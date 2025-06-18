import Foundation
import _PhotosUI_SwiftUI

final class BusinessProfileViewModel: ObservableObject {
    enum StateView {
        case createing
        case editing
    }
    
    @Published var shouldShowPhotoPicker: Bool = false
    @Published var pickerItem: PhotosPickerItem? {
        didSet {
            guard let pickerItem else { return }
            isFromGallerySelection = true
            
            Task {
                if let data = try? await pickerItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        self.selectedImageData = data
                    }
                }
            }
        }
    }
    @Published var selectedImageData: Data?
    @Published var shouldShowCropView: Bool = false
    @Published var sholdShowCurrencyPicker: Bool = false
    @Published var shouldShowFullList: Bool = false
    
    @Published var ownerName: String = ""
    @Published var mail: String = ""
    @Published var phoneNumber: String = ""
    @Published var country: String = ""
    @Published var city: String = ""
    @Published var street: String = ""
    @Published var apartment: String = ""
    @Published var postcode: String = ""
    @Published var currency: Currency = .USD
    
    @Published var shouldShowOwnerNameError: Bool = false
    @Published var shouldShowMailError: Bool = false
    @Published var shouldShowPhoneNumberError: Bool = false
    
    private var isFromGallerySelection = false
    private let stateView: StateView
    private let dataBaseManager: CoreDataManager = .shared
    
    init(stateView: StateView) {
        self.stateView = stateView
    }
    
    func tapOnPhoto() {
        shouldShowPhotoPicker = true
    }
    
    func tapOnCrop(_ bool: Bool = true) {
        shouldShowCropView = bool
    }
    
    func setEditedImage(_ data: Data?) {
        selectedImageData = data
    }
    
    func resetImage() {
        pickerItem = nil
        selectedImageData = nil
    }
    
    func resetGallerySelectionFlag() {
        isFromGallerySelection = false
    }
    
    func getGallerySelectionFlag() -> Bool {
        isFromGallerySelection
    }
    
    func tapOnCurrencyButton() {
        sholdShowCurrencyPicker = true
    }
    
    func tapOnMoreDetails() {
        shouldShowFullList.toggle()
    }
    
    @MainActor
    func tapOnSaveButton(completion: @escaping () -> Void) {
        guard !ownerName.isEmpty else {
            shouldShowOwnerNameError = true
            return
        }
        
        guard !mail.isEmpty else {
            shouldShowMailError = true
            return
        }
        
        guard !phoneNumber.isEmpty else {
            shouldShowPhoneNumberError = true
            return
        }
        
        Task {
            let input = BusinessProfileInput(
                ownerName: ownerName,
                email: mail,
                phoneNumber: phoneNumber,
                currency: currency.rawValue,
                country: country,
                city: city,
                street: street,
                apartment: apartment,
                postalCode: postcode,
                imageData: selectedImageData
            )
            
            do {
                try await dataBaseManager.createBusinessProfile(input: input)
                completion()
            } catch {
                
            }
        }
    }
}
