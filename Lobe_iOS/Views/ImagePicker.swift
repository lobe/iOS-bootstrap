//
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import SwiftUI

/* Image picker. */
struct ImagePicker: UIViewControllerRepresentable {
  // dismisses view when document is selected
  @Environment(\.presentationMode) var presentationMode
  
  typealias UIViewControllerType = UIImagePickerController
  typealias Coordinator = ImagePickerCoordinator
  
  @Binding var image: UIImage?
  @Binding var viewMode: PlayViewMode
  let predictionLayer: PredictionLayer
  
  var sourceType: UIImagePickerController.SourceType = .camera
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
  }
  
  func makeCoordinator() -> ImagePicker.Coordinator {
    ImagePickerCoordinator(self)
  }
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = sourceType
    picker.delegate = context.coordinator
    picker.modalPresentationStyle = .fullScreen
    return picker
  }
  
  class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var parent: ImagePicker
    
    init(_ parent: ImagePicker) {
      self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      defer { parent.presentationMode.wrappedValue.dismiss() }
      
      if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        self.parent.image = uiImage
        self.parent.predictionLayer.getPrediction(forImage: uiImage)
        self.parent.viewMode = .ImagePreview
      }
    }
  }
}
