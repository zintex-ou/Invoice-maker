import Foundation
import PhotosUI
import SwiftUI

@MainActor
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
    @Published var shouldShowFullList: Bool = false
    
    @Published var ownerName: String = ""
    @Published var mail: String = ""
    @Published var phoneNumber: String = ""
    @Published var country: String = ""
    @Published var city: String = ""
    @Published var street: String = ""
    @Published var apartment: String = ""
    @Published var postcode: String = ""
    
    @Published var shouldShowOwnerNameError: Bool = false
    @Published var shouldShowMailError: Bool = false
    @Published var shouldShowPhoneNumberError: Bool = false
    @Published var shouldShowAlert: Bool = false
    
    private var isFromGallerySelection = false
    private let dataBaseManager: CoreDataManager = .shared
    
    let stateView: StateView
    var alert: AlertModel = .init(title: "", subtitle: "")
    
    init(stateView: StateView) {
        self.stateView = stateView
        
        if stateView == .editing {
            fetchBussinessProfile()
        }
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
    
    func tapOnMoreDetails() {
        shouldShowFullList.toggle()
    }
    
    func getButtonTitle() -> String {
        stateView == .createing ? "Continue" : "Save"
    }
    
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
        
        guard !ownerName.isValidPunctuationAndNewlinesOnly() else {
            alert = .init(
                title: "Invalid Name",
                subtitle: "The name you entered contains only punctuation or spacing characters. Please enter a valid name using letters or numbers."
            )
            shouldShowAlert = true
            return
        }
        
        guard mail.isValidEmail() else {
            alert = .init(
                title: "Invalid Email",
                subtitle: "The email address you provided doesn't match the required format. Please enter a valid email (e.g. name@example.com)."
            )
            shouldShowAlert = true
            return
        }
        
        guard !phoneNumber.isValidPunctuationAndNewlinesOnly() else {
            alert = .init(
                title: "Invalid Phone Number",
                subtitle: "The phone number you entered contains only punctuation or empty characters. Please provide a valid phone number with digits."
            )
            shouldShowAlert = true
            return
        }
        
        Task {
            let input = BusinessProfileInput(
                ownerName: ownerName,
                email: mail,
                phoneNumber: phoneNumber,
                country: country,
                city: city,
                street: street,
                apartment: apartment,
                postalCode: postcode,
                imageData: selectedImageData
            )
            
            do {
                if stateView == .editing {
                    try await dataBaseManager.updateBusinessProfile(input: input)
                } else {
                    try await dataBaseManager.createBusinessProfile(input: input)
                }
                completion()
            } catch {
                self.alert = .init(
                    title: "Failed to Save Profile",
                    subtitle: "An error occurred while saving your business profile. Please try again later."
                )
                shouldShowAlert = true
            }
        }
    }
    
    private func fetchBussinessProfile() {
        Task {
            do {
                guard let result = try await dataBaseManager.fetchBusinessProfile() else { return }
                self.ownerName = result.ownerName ?? ""
                self.mail = result.email ?? ""
                self.phoneNumber = result.phoneNumber ?? ""
                self.country = result.country ?? ""
                self.city = result.city ?? ""
                self.selectedImageData = result.image
                self.postcode = result.postalCode ?? ""
                self.street = result.street ?? ""
                self.apartment = result.apartment ?? ""
            } catch {
                self.alert = .init(
                    title: "Failed to Fetch Profile",
                    subtitle: "An error occurred while fetching your business profile. Please try again later."
                )
                shouldShowAlert = true
            }
        }
    }
}
