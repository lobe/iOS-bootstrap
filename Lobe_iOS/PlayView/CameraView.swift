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
        /// Wrapper for screen shot..
        func takeScreenShot(inView view: UIView) {
            guard let camImage = self.parent.viewModel.image else {
                fatalError("Could not call takeScreenShot")
            }
            let imageView = UIImageView(image: camImage)
            screenShotAnimate(inView: view, imageView: imageView)
            screenShotSaveToLibrary(imageView: imageView)
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
            
            if self.parent.viewModel.viewMode == .Camera {
                UIView.transition(with: view, duration: 1, options: .curveEaseIn, animations: nil)
                view.addSubview(imageView)
                self.parent.viewModel.viewMode = .ImagePreview
            }
        }
        
        /// Saves screen shot photo to library.
        private func screenShotSaveToLibrary(imageView: UIImageView) {
            guard let layer = UIApplication.shared.windows.first(where: \.isKeyWindow)?.layer else {
                fatalError("Could not get layer for keyWindow")
            }
            
            // Must be called before screenshot context is gathered
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
            
            // Get screenshot data
            guard let uiGraphicsCtx = UIGraphicsGetCurrentContext() else {
                fatalError("Could not get screenshot context")
            }
            layer.render(in: uiGraphicsCtx)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            guard let camImage = self.parent.viewModel.image, screenshot != nil else {
                fatalError("Unable to save screenshot")
            }
            UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
            imageView.removeFromSuperview()
            self.parent.viewModel.viewMode = .Camera
            self.parent.viewModel.image = camImage
        }
        
        /// Sets view model image.
        func setCameraImage(with croppedImage: UIImage) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.viewModel.image = croppedImage
            }
        }
    }
}
