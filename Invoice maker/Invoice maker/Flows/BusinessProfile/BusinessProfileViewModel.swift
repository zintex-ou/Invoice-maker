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
    
    private var isFromGallerySelection = false
    private let stateView: StateView
    
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
}
