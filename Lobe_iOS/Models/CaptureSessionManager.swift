//
//  CaptureSessionViewModel.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 12/27/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import AVKit
import Combine
import SwiftUI
import VideoToolbox

/// View model for camera view.
class CaptureSessionManager: NSObject {
    @Published var captureDevice: AVCaptureDevice?
    @Published var isEnabled = false
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var imageForPrediction: UIImage?
    let predictionLayer: PredictionLayer
    var captureSession: AVCaptureSession?
    var backCam: AVCaptureDevice?
    var frontCam: AVCaptureDevice?
    var dataOutput: AVCaptureVideoDataOutput?
    private var disposables = Set<AnyCancellable>()
    private var totalFrameCount = 0
    
    init(predictionLayer: PredictionLayer) {
        self.predictionLayer = predictionLayer
        
        /// Init devices.
        self.backCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first
        self.frontCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first
        self.captureDevice = backCam
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
    }
}

extension CaptureSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// Delegate method for `AVCaptureVideoDataOutputSampleBufferDelegate`: formats image for inference.
    /// The delegate is set in the capture session view model.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        /// Skip frames to optimize.
        totalFrameCount += 1
        if totalFrameCount % 20 != 0{ return }
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let image = UIImage(pixelBuffer: pixelBuffer),
                let previewLayer = self.previewLayer,
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

        // Rotate and crop the captured image to be the size of the screen.
        let isUsingFrontCam = self.captureDevice == self.frontCam
        guard let rotatedImage = image.rotate(radians: radiansToRotate, flipX: isUsingFrontCam),
              let squaredImage = rotatedImage.squared() else {
            fatalError("Could not rotate or crop image.")
        }

        self.imageForPrediction = squaredImage
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
