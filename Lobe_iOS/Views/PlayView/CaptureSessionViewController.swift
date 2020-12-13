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

/// Camera session; ML request handling.
class CaptureSessionViewController: UIViewController {
    var backCam: AVCaptureDevice?
    var frontCam: AVCaptureDevice?
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var totalFrameCount = 0
    var tripleTapGesture: UITapGestureRecognizer?
    var doubleTapGesture: UITapGestureRecognizer?

    var delegate: CameraViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Define gesture event listeners
        let doubleTapGesture = UITapGestureRecognizer(target: self, action:#selector(self.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        let tripleTapGesture = UITapGestureRecognizer(target: self, action:#selector(self.handleTripleTap(_:)))
        tripleTapGesture.numberOfTapsRequired = 3
        view.addGestureRecognizer(tripleTapGesture)
        doubleTapGesture.require(toFail: tripleTapGesture)
        
        self.doubleTapGesture = doubleTapGesture
        self.tripleTapGesture = tripleTapGesture
        self.backCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first
        self.frontCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first
        
        self.captureDevice = backCam
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCaptureSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.captureSession?.stopRunning()
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
    
    /// Double tap flips camera.
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.flipCamera(inView: view)
    }
    
    /// Triple tap creates screen shot.
    @objc func handleTripleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.delegate?.takeScreenShot(inView: view)
    }
    
    /// Swaps camera view between front and back
    @objc func flipCamera(inView view: UIView) {
        UIView.transition(with: view, duration: 0.5, options: .transitionFlipFromLeft, animations: nil)
        self.captureDevice = (captureDevice == backCam) ? frontCam : backCam

        self.captureSession?.stopRunning()
        startCaptureSession()
    }

    func startCaptureSession() {
        self.captureSession = AVCaptureSession()
        guard let captureSession = self.captureSession,
              let captureDevice = self.captureDevice
        else {
            print("Could not instantiate capture session on viewDidLoad")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Could not create AVCaptureDeviceInput in viewDidLoad.")
        }
        
        captureSession.startRunning()
        setPreviewLayer()
        setOutput()
    }

    func setPreviewLayer() {
        guard let captureSession = self.captureSession else {
            fatalError("Preview layer not set.")
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        configureVideoOrientation(for: previewLayer)
        view.layer.addSublayer(previewLayer)
        
        self.previewLayer = previewLayer
    }

    func setOutput() {
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        self.captureSession?.addOutput(dataOutput)
    }

    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let cam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position).devices
        return cam.first
    }
    
    /// Configures orientation of preview layer for AVCapture session.
    private func configureVideoOrientation(for previewLayer: AVCaptureVideoPreviewLayer?) {
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

/// Defines delegate method.
extension CaptureSessionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        /* Skip frames to optimize. */
        totalFrameCount += 1
        if totalFrameCount % 20 != 0{ return }
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let curImg = UIImage(pixelBuffer: pixelBuffer),
              let previewLayer = self.previewLayer,
              let videoOrientation = previewLayer.connection?.videoOrientation
        else {
            print("Failed creating image at captureOutput.")
            return
        }
        
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

        // rotatedimage is 1000% broken
        let rotatedImage = curImg.rotate(radians: radiansToRotate)

        /* Crop the captured image to be the size of the screen. */
        guard let croppedImage = rotatedImage.crop(height: previewLayer.bounds.height, width: previewLayer.bounds.width) else {
            fatalError("Could not crop image.")
        }
        
        self.delegate?.setCameraImage(with: croppedImage)
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
    func crop(isOpaque: Bool = false, height: CGFloat, width: CGFloat) -> UIImage? {
        let newWidth = size.width
        let newHeight = height / width * size.width
        var screenSize: CGSize  { .init(width: newWidth, height: newHeight)}
        guard let cgImage = cgImage?
                .cropping(to: .init(origin: .init(x: 0,
                                                  y: ((size.height - newHeight) / 2)),
                                    size: screenSize)) else { return nil }
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: screenSize, format: format).image { _ in
            UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
                .draw(in: .init(origin: .zero, size: screenSize))
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
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return rotatedImage ?? self
        }
        return self
    }
    
//    func rotated(byDegrees degrees: CGFloat) -> UIImage! {
//        // calculate the size of the rotated view's containing box for our drawing space
//        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
//        let t = CGAffineTransform(rotationAngle: DegreesToRadians(degrees))
//        rotatedViewBox.transform = t
//        let rotatedSize = rotatedViewBox.frame.size
//
//        // Create the bitmap context
//        UIGraphicsBeginImageContext(rotatedSize)
//        let bitmap = UIGraphicsGetCurrentContext()
//
//        // Move the origin to the middle of the image so we will rotate and scale around the center.
//        bitmap?.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2)
//
//        //   // Rotate the image context
//        bitmap?.rotate(by: DegreesToRadians(degrees))
//
//        // Now, draw the rotated/scaled image into the context
//        bitmap?.scaleBy(x: 1.0, y: -1.0)
//        bitmap?.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
//
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage
//
//    }
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
