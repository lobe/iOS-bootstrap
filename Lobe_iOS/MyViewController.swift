//
//  MyViewController.swift
//  Lobe_iOS
//
//  Created by Kathy Zhou on 6/4/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import SwiftUI
import AVKit
import Vision

struct MyRepresentable: UIViewControllerRepresentable{
    
    @State var controller: MyViewController
    var project: Project?

    func makeUIViewController(context: Context) -> MyViewController {
        return self.controller
    }
    func updateUIViewController(_ uiViewController: MyViewController, context: Context) {
        guard let project = self.project else { return }
        uiViewController.project = project
    }
}

/* Camera session; ML request handling. */
class MyViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {

    @Published var classificationLabel: String?
    var backCam: AVCaptureDevice!
    var frontCam: AVCaptureDevice!
    var captureDevice: AVCaptureDevice!
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var useCam: Bool = true
    var img: UIImage?
    var confidence: Float?
    var camImage: UIImage?
    var totalFrameCount = 0
    var project: Project?

    var tripleTapGesture = UITapGestureRecognizer()
    var doubleTapGesture = UITapGestureRecognizer()
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer? = nil) {
        flipCamera()
    }
    @objc func handleTripleTap(_ sender: UITapGestureRecognizer? = nil) {
        screenShotMethod()
    }
    @objc func screenShotMethod() {
        let imageView = UIImageView(image: self.camImage!)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.frame
        
        let black = UIImage(named: "Black")
        let blackView = UIImageView(image: black)
        imageView.contentMode = .scaleAspectFill
        blackView.frame = view.frame
        view.addSubview(blackView)
        blackView.alpha = 1
        
        /* Shutter animation. */
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            blackView.alpha = 0
        }, completion: nil)
        
        if useCamera{
            UIView.transition(with: view, duration: 1, options: .curveEaseIn, animations: nil)
            view.addSubview(imageView)
            self.changeStatus(useCam: false, img: camImage!)
        }
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
        if useCamera {
            imageView.removeFromSuperview()
            self.changeStatus(useCam: true, img: self.camImage!)
        }
    }
    @objc func flipCamera() {
       UIView.transition(with: view, duration: 0.5, options: .transitionFlipFromLeft, animations: nil)
       if captureDevice == backCam{
           captureDevice = frontCam}
       else {
           captureDevice = backCam}
        captureSession = AVCaptureSession()
        guard let input = try? AVCaptureDeviceInput(device: self.captureDevice) else {return}
        captureSession.addInput(input)
        captureSession.startRunning()
        setPreviewLayer()
        setOutput()
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action:#selector(self.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        tripleTapGesture = UITapGestureRecognizer(target: self, action:#selector(self.handleTripleTap(_:)))
        tripleTapGesture.numberOfTapsRequired = 3
        view.addGestureRecognizer(tripleTapGesture)
        doubleTapGesture.require(toFail: tripleTapGesture)
        
        backCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first
        frontCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first
        captureDevice = backCam
        let input: AVCaptureInput!
        if self.captureDevice != nil {
            input = try! AVCaptureDeviceInput(device: self.captureDevice)
        } else {
            return
        }
        captureSession.addInput(input)
        captureSession.startRunning()
        setPreviewLayer()
        setOutput()
    }
    func setPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        previewLayer!.frame = view.frame
    }
    func setOutput() {
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let cam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position).devices
        return cam.first
    }
    func changeStatus(useCam: Bool, img: UIImage){
        if useCam {
            self.useCam = true
            self.img = nil
        } else {
            self.useCam = false
            self.img = img
        }
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        /* Skip frames to optimize. */
        totalFrameCount += 1
        if totalFrameCount % 20 != 0{ return }
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    
        let curImg = UIImage(pixelBuffer: pixelBuffer)
        let rotatedImage = curImg!.rotate(radians: .pi / 2)
        /* Crop the captured image to be the size of the screen. */
        self.camImage = rotatedImage.crop(height: (previewLayer?.frame.height)!, width: (previewLayer?.frame.width)!)
        
        guard let model = self.project?.model else { return }
        let request = VNCoreMLRequest(model: model) { (finishReq, err) in
            self.processClassifications(for: finishReq, error: err)
        }
        
        /* Crop to square images and send to the model. */
        if self.useCam {
            try? VNImageRequestHandler(ciImage: CIImage(cgImage: (self.camImage?.squared()?.cgImage!)!)).perform([request])
        } else {
            try? VNImageRequestHandler(ciImage: CIImage(cgImage: (self.img?.squared()?.cgImage!)!)).perform([request])
        }
    }
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            let classifications = results as! [VNClassificationObservation]

            if classifications.isEmpty {
                self.classificationLabel = "Nothing recognized."
            } else {
                /* Display top classifications ranked by confidence in the UI. */
                let topClassifications = classifications.prefix(1)
                self.classificationLabel = topClassifications[0].identifier
                self.confidence = topClassifications[0].confidence
            }
        }
    }
}

/* Helpers for editing images. */
import VideoToolbox
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
}
