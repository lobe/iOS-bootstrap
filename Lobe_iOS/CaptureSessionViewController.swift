//
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
/// 2. Managing tap gestures.
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
    if let preview = previewLayer {
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
