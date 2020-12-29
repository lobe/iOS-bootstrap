//
//  PredictionLayer.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/30/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import AVKit
import Combine
import Foundation
import SwiftUI
import Vision
import VideoToolbox

/// Backend logic for predicting classifiers for a given image.
class PredictionLayer: NSObject {
    @Published var classificationResult: VNClassificationObservation?
    var model: VNCoreMLModel?
    var totalFrameCount = 0
    
    init(model: VNCoreMLModel?) {
        self.model = model
    }
    
    /// Prediction handler which updates `classificationResult` publisher.
    func getPrediction(forImage image: UIImage) {
        let requestHandler = createPredictionRequestHandler(forImage: image)
        let request = createModelRequest(
            /// Set classification result to publisher
            onComplete: { [weak self] request in
                guard let classifications = request.results as? [VNClassificationObservation],
                      !classifications.isEmpty else {
                    self?.classificationResult = nil
                    return
                }
                let topClassifications = classifications.prefix(1)
                self?.classificationResult = topClassifications[0]
            }, onError: { [weak self] error in
                print("Error getting predictions: \(error)")
                self?.classificationResult = nil
            })
        
        try? requestHandler.perform([request])
    }
    
    /// Creates request handler and formats image for prediciton processing.
    func createPredictionRequestHandler(forImage image: UIImage) -> VNImageRequestHandler {
        /* Crop to square images and send to the model. */
        guard let cgImage = image.cgImage else {
            fatalError("Could not create cgImage in captureOutput")
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        let requestHandler = VNImageRequestHandler(ciImage: ciImage)
        return requestHandler
    }
    
    func createModelRequest(onComplete: @escaping (VNRequest) -> (), onError: @escaping (Error) -> ()) -> VNCoreMLRequest {
        guard let model = model else {
            fatalError("Model not found in prediction layer")
        }

        let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
            if let error = error {
                onError(error)
            }
            onComplete(request)
        })
        return request
    }    
}

extension PredictionLayer: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// Delegate method for `AVCaptureVideoDataOutputSampleBufferDelegate`: formats image for inference.
    /// The delegate is set in the capture session view model.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        /// Skip frames to optimize.
        totalFrameCount += 1
        if totalFrameCount % 20 != 0{ return }
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let image = UIImage(pixelBuffer: pixelBuffer) else {
//                let previewLayer = self.parent.viewModel.previewLayer,
//                let videoOrientation = previewLayer.connection?.videoOrientation else {
            print("Failed creating image at captureOutput.")
            return
        }
        
//        // Determine rotation by radians given device orientation and camera device
//        var radiansToRotate = CGFloat(0)
//        switch videoOrientation {
//        case .portrait:
//            radiansToRotate = .pi / 2
//            break
//        case .portraitUpsideDown:
//            radiansToRotate = (3 * .pi) / 2
//            break
//        case .landscapeLeft:
//            if (self.parent.viewModel.captureDevice == self.parent.viewModel.backCam) {
//                radiansToRotate = .pi
//            }
//            break
//        case .landscapeRight:
//            if (self.parent.viewModel.captureDevice == self.parent.viewModel.frontCam) {
//                radiansToRotate = .pi
//            }
//            break
//        default:
//            break
//        }
//
//        // Rotate and crop the captured image to be the size of the screen.
//        let isUsingFrontCam = self.parent.viewModel.captureDevice == self.parent.viewModel.frontCam
//        guard let rotatedImage = image.rotate(radians: radiansToRotate, flipX: isUsingFrontCam),
//                let squaredImage = rotatedImage.squared() else {
//            fatalError("Could not rotate or crop image.")
//        }
        
        
//        self.getPrediction(forImage: rotatedImage)

        // TO-DO: explore if we nee this
        /// Crop the captured image to be the size of the screen.
//        guard let croppedImage = rotatedImage.crop(height: previewLayer.frame.height, width: previewLayer.frame.width) else {
//            fatalError("Could not crop image.")
//        }
    }
}

/// Helpers for editing images.
extension UIImage {
    var isPortrait:  Bool    { size.height > size.width }
    var isLandscape: Bool    { size.width > size.height }
    var breadth:     CGFloat { min(size.width, size.height) }
    var breadthSize: CGSize  { .init(width: breadth, height: breadth) }
    
    func squared(isOpaque: Bool = false) -> UIImage? {
        guard let cgImage = cgImage?
                .cropping(to: .init(origin: .init(x: isLandscape ? ((size.width-size.height)/2).rounded(.down) : 0,
                                                  y: isPortrait  ? ((size.height-size.width)/2).rounded(.down) : 0),
                                    size: breadthSize)) else { return nil }
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: breadthSize, format: format).image { _ in
            UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
                .draw(in: .init(origin: .zero, size: breadthSize))
        }
    }
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        guard let myImage = cgImage else {
            return nil
        }
        
        self.init(cgImage: myImage)
    }
    
    func rotate(radians: CGFloat, flipX: Bool = false) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        
        // Flip x-axis if specified (used to correct front-facing cam
        if flipX { context.scaleBy(x: -1, y: 1) }

        // Rotate around middle
        context.rotate(by: CGFloat(radians))

        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
