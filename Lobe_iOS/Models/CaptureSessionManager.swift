//
//  Copyright © 2020 Microsoft. All rights reserved.
//

import AVKit
import Combine
import SwiftUI
import VideoToolbox

/// View model for camera view.
class CaptureSessionManager: NSObject {
  @Published var previewLayer: AVCaptureVideoPreviewLayer?
  @Published var capturedImageOutput: UIImage?
  var captureSession: AVCaptureSession?
  private var backCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first
  private var frontCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first
  private var dataOutput: AVCaptureVideoDataOutput?
  private var captureDevice: AVCaptureDevice?
  private var disposables = Set<AnyCancellable>()
  private var totalFrameCount = 0
  
  override init() {
    self.captureDevice = self.backCam
  }
  
  /// Resets camera feed, which:
  /// 1. Creates capture session for specified device.
  /// 2. Creates preview layer.
  /// 3. Creates new video data output.
  /// 4. Starts capture session.
  func resetCameraFeed() {
    guard let captureDevice = self.captureDevice else {
      print("No capture device found on reset camera feed.")
      return
    }
    /// Tear down existing capture session to remove output for buffer delegate.
    self.captureSession = nil
    self.dataOutput = nil
    
    /// Create new capture session and preview layer.
    let captureSession = self.createCaptureSession(for: captureDevice)
    let previewLayer = self.createPreviewLayer(for: captureSession)
    let dataOutput = AVCaptureVideoDataOutput()
    
    /// Set delegate of video output buffer to self.
    dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    captureSession.startRunning()
    captureSession.addOutput(dataOutput)
    
    self.captureSession = captureSession
    self.previewLayer = previewLayer
    self.dataOutput = dataOutput
  }
  
  /// On disable, stop running capture session and then tear down.
  /// Both steps are required to prroperly shut down camera session.
  func tearDown() {
    self.captureSession?.stopRunning()
    self.captureSession = nil
  }
  
  /// Creates a capture session given input device as param.
  private func createCaptureSession(for captureDevice: AVCaptureDevice) -> AVCaptureSession {
    let captureSession = AVCaptureSession()
    
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(input)
    } catch {
      print("Could not create AVCaptureDeviceInput in viewDidLoad.")
    }
    
    return captureSession
  }
  
  /// Sets up preview layer which gets displayed in view controller.
  func createPreviewLayer(for captureSession: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    return previewLayer
  }
  
  /// Toggles between front and back cam.
  func rotateCamera() {
    self.captureDevice = (captureDevice == backCam) ? frontCam : backCam
    self.resetCameraFeed()
  }
  
  /// Wrapper for screen shot.
  func takeScreenShot(in view: UIView) {
    guard let camImage = self.capturedImageOutput else {
      fatalError("Could not call takeScreenShot")
    }
    
    /// Create a `UIImageView` for overlaying the shutter animation over the camera view.
    /// Remove it from the super view after image is saved to storage.
    let imageView = UIImageView(image: camImage)
    screenShotAnimate(in: view, imageView: imageView)
    UIImageWriteToSavedPhotosAlbum(camImage, nil, nil, nil)
    imageView.removeFromSuperview()
  }
  
  /// Provides flash animation when screenshot is triggered.
  private func screenShotAnimate(in view: UIView, imageView: UIImageView) {
    imageView.contentMode = .scaleAspectFit
    imageView.frame = view.frame
    
    let black = UIImage(named: "Black")
    let blackView = UIImageView(image: black)
    imageView.contentMode = .scaleAspectFill
    blackView.frame = view.frame
    view.addSubview(blackView)
    blackView.alpha = 1
    
    /// Shutter animation.
    UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
      blackView.alpha = 0
    }, completion: nil)
  }
}

extension CaptureSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  /// Delegate method for `AVCaptureVideoDataOutputSampleBufferDelegate`: formats image for inference.
  /// The delegate is set in the capture session view model.
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    /// Skip frames to optimize.
    totalFrameCount += 1
    if totalFrameCount % 20 != 0 { return }
    
    guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
          let image = UIImage(pixelBuffer: pixelBuffer),
          let previewLayer = self.previewLayer,
          let videoOrientation = previewLayer.connection?.videoOrientation else {
      print("Failed creating image at captureOutput.")
      return
    }
    
    /// Determine rotation by radians given device orientation and camera device
    var radiansToRotate = CGFloat(0)
    switch videoOrientation {
    case .portrait:
      radiansToRotate = .pi / 2
      break
    case .portraitUpsideDown:
      radiansToRotate = (3 * .pi) / 2
      break
    case .landscapeLeft:
      if (self.captureDevice == self.backCam) {
        radiansToRotate = .pi
      }
      break
    case .landscapeRight:
      if (self.captureDevice == self.frontCam) {
        radiansToRotate = .pi
      }
      break
    default:
      break
    }
    
    /// Rotate image and flip over x-axis if using front-facing cam.
    let isUsingFrontCam = self.captureDevice == self.frontCam
    guard let rotatedImage = image.rotate(radians: radiansToRotate, flipX: isUsingFrontCam) else {
      fatalError("Could not rotate or crop image.")
    }
    
    self.capturedImageOutput = rotatedImage
  }
}

/// Helpers for editing images.
extension UIImage {
  var isPortrait:  Bool    { size.height > size.width }
  var isLandscape: Bool    { size.width > size.height }
  var breadth:     CGFloat { min(size.width, size.height) }
  var breadthSize: CGSize  { .init(width: breadth, height: breadth) }

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
