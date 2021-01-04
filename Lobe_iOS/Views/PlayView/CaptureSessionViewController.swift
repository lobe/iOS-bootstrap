//
//  CaptureSessionViewController.swift
//  Lobe_iOS
//
//  Created by Kathy Zhou on 6/4/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import AVKit
import Foundation

/// Defines tap gesture delegate protocol.
protocol CaptureSessionGestureDelegate {
    func viewRecognizedDoubleTap()
    func viewRecognizedTripleTap(_ view: UIView)
}

/// View controller for video capture session. It's responsibilities include:
/// 1. Setting camera output to UI view.
/// 2. Handling orientation changes.
/// 3. Handles double and triple tap gestures (since SwiftUI seems to struggle with managing multiple tap gestures).
class CaptureSessionViewController: UIViewController {
    var previewLayer: AVCaptureVideoPreviewLayer?
    var tripleTapGesture: UITapGestureRecognizer?
    var doubleTapGesture: UITapGestureRecognizer?
    var gestureDelegate: CaptureSessionGestureDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Define gesture event listeners. We don't use SwiftUI since there isn't support for
        /// recognizing a double tap gesture when a triple tap gesture is also present.
        let doubleTapGesture = UITapGestureRecognizer(target: self, action:#selector(self.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        let tripleTapGesture = UITapGestureRecognizer(target: self, action:#selector(self.handleTripleTap(_:)))
        tripleTapGesture.numberOfTapsRequired = 3
        view.addGestureRecognizer(tripleTapGesture)
        doubleTapGesture.require(toFail: tripleTapGesture)
    }
    
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
    
    /// Double tap flips camera.
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.gestureDelegate?.viewRecognizedDoubleTap()
    }
    
    /// Triple tap creates screen shot.
    @objc func handleTripleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.gestureDelegate?.viewRecognizedTripleTap(self.view)
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
