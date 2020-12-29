//
//  CaptureSessionViewController.swift
//  Lobe_iOS
//
//  Created by Kathy Zhou on 6/4/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import AVKit
import Foundation

/// View controller for video capture session. It's responsibilities include:
/// 1. Setting camera output to UI view.
/// 2. Handling orientation changes.
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
