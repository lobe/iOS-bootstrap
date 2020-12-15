//
//  CameraView.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/29/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Vision

protocol CameraViewDelegate: class {
    /// Signals to delegate when screenshot is ready to be taken.
    func takeScreenShot(inView view: UIView)
    
    /// Binds camera image to delegate.
    func setCameraImage(with croppedImage: UIImage)
}


struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: PlayViewModel

    func makeUIViewController(context: Context) -> CaptureSessionViewController {
        let vc = CaptureSessionViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CaptureSessionViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraViewDelegate {
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        /// Wrapper for screen shot, which saves to storage the image which gets used for inference.
        func takeScreenShot(inView view: UIView) {
            guard let camImage = self.parent.viewModel.image else {
                fatalError("Could not call takeScreenShot")
            }

            /// Create a `UIImageView` for overlaying the shutter animation over the camera view.
            /// Remove it from the super view after image is saved to storage.
            let imageView = UIImageView(image: camImage)
            screenShotAnimate(inView: view, imageView: imageView)
            UIImageWriteToSavedPhotosAlbum(camImage, nil, nil, nil)
            imageView.removeFromSuperview()
        }
        
        /// Provides flash animation when screenshot is triggered.
        private func screenShotAnimate(inView view: UIView, imageView: UIImageView) {
            imageView.contentMode = .scaleAspectFit
            imageView.frame = view.frame
            
            let black = UIImage(named: "Black")
            let blackView = UIImageView(image: black)
            imageView.contentMode = .scaleAspectFill
            blackView.frame = view.frame
            view.addSubview(blackView)
            blackView.alpha = 1
            
            /* Shutter animation. */
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                blackView.alpha = 0
            }, completion: nil)
        }
        
        /// Sets view model image.
        func setCameraImage(with croppedImage: UIImage) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.viewModel.image = croppedImage
            }
        }
    }
}
