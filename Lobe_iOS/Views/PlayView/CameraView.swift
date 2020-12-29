//
//  CameraView.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/29/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import AVKit
import SwiftUI
import UIKit
import Vision

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: CaptureSessionViewModel

    func makeUIViewController(context: Context) -> CaptureSessionViewController {
        CaptureSessionViewController()
    }
    
    /// Update preview layer when state changes for camera device
    func updateUIViewController(_ uiViewController: CaptureSessionViewController, context: Context) {
        /// Set view with previewlayer
        let previewLayer = self.viewModel.previewLayer
        uiViewController.previewLayer = previewLayer
        uiViewController.configureVideoOrientation(for: previewLayer)
        if previewLayer != nil { uiViewController.view.layer.addSublayer(previewLayer!) }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }

        /// Wrapper for screen shot.
        func takeScreenShot(inView view: UIView) {
            // guard let camImage = self.parent.viewModel.image else {
            //     fatalError("Could not call takeScreenShot")
            // }

            // /// Create a `UIImageView` for overlaying the shutter animation over the camera view.
            // /// Remove it from the super view after image is saved to storage.
            // let imageView = UIImageView(image: camImage)
            // screenShotAnimate(inView: view, imageView: imageView)
            // UIImageWriteToSavedPhotosAlbum(camImage, nil, nil, nil)
            // imageView.removeFromSuperview()
        }
        
        /// Provides flash animation when screenshot is triggered.
        private func screenShotAnimate(inView view: UIView, imageView: UIImageView) {
            // imageView.contentMode = .scaleAspectFit
            // imageView.frame = view.frame
            
            // let black = UIImage(named: "Black")
            // let blackView = UIImageView(image: black)
            // imageView.contentMode = .scaleAspectFill
            // blackView.frame = view.frame
            // view.addSubview(blackView)
            // blackView.alpha = 1
            
            // /* Shutter animation. */
            // UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            //     blackView.alpha = 0
            // }, completion: nil)
        }
    }
}
