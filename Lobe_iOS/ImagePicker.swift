//
//  ImagePicker.swift
//  Lobe_iOS
//
//  Created by Kathy Zhou on 5/27/20.
//  Copyright © 2020 Adam Menges. All rights reserved.
//


import Foundation
import SwiftUI

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var image: UIImage?
    @Binding var isShown: Bool
    var controller: MyViewController
    
    init(image: Binding<UIImage?>, isShown: Binding<Bool>, controller: MyViewController) {
        _image = image
        _isShown = isShown
        self.controller = controller
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = uiImage
            isShown = false
            useCamera = false
            controller.changeStatus(useCam: false, img: uiImage)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
        self.controller.changeStatus(useCam: true, img: self.controller.camImage!)
    }

}

/* Image picker. */
struct ImagePicker: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerCoordinator
    
    @Binding var image: UIImage?
    @Binding var isShown: Bool
    var controller: MyViewController
    var sourceType: UIImagePickerController.SourceType = .camera
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    func makeCoordinator() -> ImagePicker.Coordinator {
        return ImagePickerCoordinator(image: $image, isShown: $isShown, controller: controller)
    }
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.modalPresentationStyle = .fullScreen
        return picker
    }
    
}
