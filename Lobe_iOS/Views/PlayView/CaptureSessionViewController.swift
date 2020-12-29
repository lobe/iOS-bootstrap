//
//  CaptureSessionViewController.swift
//  Lobe_iOS
//
//  Created by Kathy Zhou on 6/4/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import AVKit
import Foundation
import VideoToolbox

/// View controller for setting camera output to UI view.
class CaptureSessionViewController: UIViewController {
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// Set video configuration for subview layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.configureVideoOrientation(for: self.previewLayer)
    }
    
    /// Update video configuration when device orientation changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.configureVideoOrientation(for: self.previewLayer)
    }
    
    /// Swaps camera view between front and back
//    @objc func flipCamera(inView view: UIView) {
//        UIView.transition(with: view, duration: 0.5, options: .transitionFlipFromLeft, animations: nil)
//        self.captureDevice = (captureDevice == backCam) ? frontCam : backCam
//
//        self.captureSession?.stopRunning()
//        startCaptureSession()
//    }
    
    /// Configures orientation of preview layer for AVCapture session.
    func configureVideoOrientation(for previewLayer: AVCaptureVideoPreviewLayer?) {
        if let preview = previewLayer,
           let connection = preview.connection {
            let orientation = UIDevice.current.orientation
            
            if connection.isVideoOrientationSupported {
                var videoOrientation: AVCaptureVideoOrientation
                
                switch orientation {
                case .portrait:
                    videoOrientation = .portrait
                case .portraitUpsideDown:
                    videoOrientation = .portraitUpsideDown
                case .landscapeLeft:
                    videoOrientation = .landscapeRight
                case .landscapeRight:
                    videoOrientation = .landscapeLeft
                default:
                    videoOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.asAVCaptureVideoOrientation() ?? .portrait
                }
                preview.frame = self.view.bounds
                connection.videoOrientation = videoOrientation
            }
            preview.frame = self.view.bounds
            
        }
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

/// Conversion helper for AVCaptureSession orientation changes.
extension UIInterfaceOrientation {
    func asAVCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
}
