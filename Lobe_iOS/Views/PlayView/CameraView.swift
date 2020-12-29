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
    @Binding var imageForInference: UIImage?

    func makeUIViewController(context: Context) -> CaptureSessionViewController {
        self.viewModel.dataOutput?.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        return CaptureSessionViewController()
    }
    
    /// Update preview layer when state changes for camera device
    func updateUIViewController(_ uiViewController: CaptureSessionViewController, context: Context) {
        /// Set view with previewlayer
        let previewLayer = self.viewModel.previewLayer
        uiViewController.previewLayer = previewLayer
        uiViewController.configureVideoOrientation(for: previewLayer)
        if previewLayer != nil { uiViewController.view.layer.addSublayer(previewLayer!) }
        
        /// Set data output delegate
        self.viewModel.dataOutput?.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        var totalFrameCount = 0
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        /// Delegate method for `AVCaptureVideoDataOutputSampleBufferDelegate`: formats image for inference
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            /// Skip frames to optimize.
            totalFrameCount += 1
            if totalFrameCount % 20 != 0{ return }
            
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
                  let image = UIImage(pixelBuffer: pixelBuffer),
                  let previewLayer = self.parent.viewModel.previewLayer,
                  let videoOrientation = previewLayer.connection?.videoOrientation else {
                print("Failed creating image at captureOutput.")
                return
            }
            
            // Determine rotation by radians given device orientation and camera device
            var radiansToRotate = CGFloat(0)
            switch videoOrientation {
            case .portrait:
                radiansToRotate = .pi / 2
                break
            case .portraitUpsideDown:
                radiansToRotate = (3 * .pi) / 2
                break
            case .landscapeLeft:
                if (self.parent.viewModel.captureDevice == self.parent.viewModel.backCam) {
                    radiansToRotate = .pi
                }
                break
            case .landscapeRight:
                if (self.parent.viewModel.captureDevice == self.parent.viewModel.frontCam) {
                    radiansToRotate = .pi
                }
                break
            default:
                break
            }
            
            // Rotate and crop the captured image to be the size of the screen.
            let isUsingFrontCam = self.parent.viewModel.captureDevice == self.parent.viewModel.frontCam
            guard let rotatedImage = image.rotate(radians: radiansToRotate, flipX: isUsingFrontCam),
                  let squaredImage = rotatedImage.squared() else {
                fatalError("Could not rotate or crop image.")
            }
            
//            self.setCameraImage(with: squaredImage)
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
