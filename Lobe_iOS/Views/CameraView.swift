//
//  Copyright © 2020 Microsoft. All rights reserved.
//

import AVKit
import SwiftUI
import UIKit
import Vision

struct CameraView: UIViewControllerRepresentable {
  var captureSessionManager: CaptureSessionManager
  
  init(captureSessionManager: CaptureSessionManager) {
    self.captureSessionManager = captureSessionManager
  }
  
  func makeUIViewController(context: Context) -> CaptureSessionViewController {
    let vc = CaptureSessionViewController()
    vc.gestureDelegate = context.coordinator
    return vc
  }
  
  /// Update preview layer when state changes for camera device
  func updateUIViewController(_ uiViewController: CaptureSessionViewController, context: Context) {
    /// Set view with previewlayer
    let previewLayer = self.captureSessionManager.previewLayer
    uiViewController.previewLayer = previewLayer
    if previewLayer != nil { uiViewController.view.layer.addSublayer(previewLayer!) }
    else { print("Preview layer null in updateUIViewController.") }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, CaptureSessionGestureDelegate {
    var parent: CameraView
    
    init(_ parent: CameraView) {
      self.parent = parent
    }
    
    func viewRecognizedDoubleTap() {
      parent.captureSessionManager.rotateCamera()
    }
    
    func viewRecognizedTripleTap(_ view: UIView) {
      parent.captureSessionManager.takeScreenShot(in: view)
    }
  }
}
