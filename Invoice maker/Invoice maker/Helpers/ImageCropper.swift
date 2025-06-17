import SwiftUI
import UIKit
import CropViewController

struct ImageCropper: UIViewControllerRepresentable{
    private let imageData: Data?
    @Environment(\.dismiss) var dismiss
    var done: (Data?) -> Void
    
    init(imageData: Data?, done: @escaping (Data?) -> Void) {
        self.imageData = imageData
        self.done = done
    }
    
    class Coordinator: NSObject, CropViewControllerDelegate{
        let parent: ImageCropper
        
        init(_ parent: ImageCropper){
            self.parent = parent
        }
        
        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            self.parent.dismiss()
            
            parent.done(image.pngData())
        }
        
        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            self.parent.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let img = UIImage(data: imageData ?? Data()) ?? UIImage()
        let cropViewController = CropViewController(image: img)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }
}
