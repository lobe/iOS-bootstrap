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
    // TO-DO: think about renaming viewmodel here
    

//    @ObservedObject var viewModel: PlayViewModel
    @ObservedObject var captureSessionViewModel: CaptureSessionViewModel

    func makeUIViewController(context: Context) -> CaptureSessionViewController {
        let vc = CaptureSessionViewController(viewModel: captureSessionViewModel)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CaptureSessionViewController, context: Context) {
        /// Update preview layer when state changes for camera device
        // TO-DO: need a check here so that this doesn't crash device
        if self.captureSessionViewModel.captureSession != nil {
            uiViewController.setPreviewLayer()
//            uiViewController.setOutput()

            /// Set data output
            let dataOutput = AVCaptureVideoDataOutput()

            guard let captureSession = self.captureSessionViewModel.captureSession,
                  captureSession.canAddOutput(dataOutput) else {
                print("Cannot add output to capture session")
                return
            }
            
            print("success")
            dataOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))

            captureSession.addOutput(dataOutput)
        }
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
            // Skip frames to optimize.
            totalFrameCount += 1
            if totalFrameCount % 20 != 0{ return }
            
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
                  let image = UIImage(pixelBuffer: pixelBuffer)
                //   let previewLayer = self.previewLayer,
                //   let videoOrientation = previewLayer.connection?.videoOrientation
            else {
                print("Failed creating image at captureOutput.")
                return
            }
            
            // Determine rotation by radians given device orientation and camera device
            // var radiansToRotate = CGFloat(0)
            // switch videoOrientation {
            //     case .portrait:
            //         radiansToRotate = .pi / 2
            //         break
            //     case .portraitUpsideDown:
            //         radiansToRotate = (3 * .pi) / 2
            //         break
            //     case .landscapeLeft:
            //         if (self.captureDevice == self.backCam) {
            //             radiansToRotate = .pi
            //         }
            //         break
            //     case .landscapeRight:
            //         if (self.captureDevice == self.frontCam) {
            //             radiansToRotate = .pi
            //         }
            //         break
            //     default:
            //         break
            // }

            // Rotate and crop the captured image to be the size of the screen.
            // let isUsingFrontCam = self.captureDevice == self.frontCam
            // guard let rotatedImage = image.rotate(radians: radiansToRotate, flipX: isUsingFrontCam),
            //       let squaredImage = rotatedImage.squared() else {
            //     fatalError("Could not rotate or crop image.")
            // }
            
            // self.setCameraImage(with: squaredImage)
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
        
        /// Sets view model image.
        func setCameraImage(with croppedImage: UIImage) {
//            DispatchQueue.main.async { [weak self] in
//                self?.parent.viewModel.image = croppedImage
//            }
        }
    }
}
