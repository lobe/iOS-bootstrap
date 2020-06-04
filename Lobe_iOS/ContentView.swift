//
//  ContentView.swift
//  Lobe_iOS
//
//  Created by Adam Menges on 5/20/20.
//  Copyright © 2020 Adam Menges. All rights reserved.
//

import SwiftUI
import AVKit
import Vision

var useCamera: Bool = true

struct ContentView: View {
    var controller: MyViewController = MyViewController()
    @State var showImagePicker: Bool = false
    @State private var image: UIImage?
    @State var scaling: CGSize = .init(width: 1, height: 1)
    @State private var offset = CGSize.zero
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                 if (self.image != nil) {
                    Image(uiImage: self.image!)
                    .resizable()
                    .aspectRatio(self.image!.size, contentMode: .fill)
                        .scaleEffect(1/self.scaling.height)
                        .offset(self.offset)
                    .gesture(DragGesture()
                        .onChanged ({value in
                            self.scaling = value.translation
                            self.scaling.height = max(self.scaling.height/50, 1)
                            self.offset = value.translation
                    })
                        .onEnded {_ in
                            self.offset = .zero
                            if self.scaling.height > 1.5{
                                self.image = nil
                                useCamera = true
                                self.controller.changeStatus(useCam: useCamera, img: self.controller.camImage!)
                            }
                            self.scaling = .init(width: 1, height: 1)
                        }
                    )
                        .opacity(1/self.scaling.height < 1 ? 0.5: 1)
                } else {
                    MyRepresentable(controller: self.controller)
                    .gesture(                                  // guesture for swiping up the photo library
                        DragGesture()
                        .onEnded {value in
                            if value.translation.height < 0 {
                                withAnimation{
                                    self.showImagePicker = true
                                }
                                self.controller.changeStatus(useCam: false, img: self.controller.camImage!)
                            }
                        }
                    )
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            
            HStack {
                Spacer()
                Image("x")     // icon for close the image
                    .resizable()
                    .opacity(self.image != nil ? 1: 0)
                    .frame(width: geometry.size.width/15, height: geometry.size.width/15)
                    .onTapGesture {
                    self.image = nil
                    useCamera = true
                    self.controller.changeStatus(useCam: useCamera, img: self.controller.camImage!)
                }
            }.padding()
            
            VStack  {
                Spacer()
                UpdateTextViewExternal(viewModel: self.controller)
                HStack {
                    
                    // button for openning the photo library
                    Button(action: {
                        withAnimation {
                            self.showImagePicker = true
                        }
                        self.controller.changeStatus(useCam: false, img: self.controller.camImage!)
                    }) {
                        Image("PhotoLib")
                            .renderingMode(.original)
                            .frame(width: geometry.size.width/3, height: geometry.size.height/16)
                    }

                    // button for taking screenshot
                    Button(action: {
                        self.controller.screenShotMethod()
                    }) {
                        Image("Button")
                            .renderingMode(.original)
                            .frame(width: geometry.size.width/3, height: geometry.size.width/9)
                    }
                    
                    // button for flipping the camera
                    Button(action: {
                        self.controller.flipCamera()
                    }) {
                        Image("Swap")
                            .renderingMode(.original)
                            .frame(width: geometry.size.width/3, height: geometry.size.height/16)
                   }

                }
                .padding()
                .frame(width: geometry.size.width,
                      height: nil, alignment: .bottom)
                    .opacity(self.image == nil ? 1: 0)  // hide the buttons when displaying an image from the photo library
            }

            ImagePicker(image: self.$image, isShown: self.$showImagePicker, controller: self.controller, sourceType: .photoLibrary)
                .edgesIgnoringSafeArea(.all)
                .offset(x:0, y:self.showImagePicker ? 0: UIApplication.shared.keyWindow?.frame.height ?? 0)
        }
    }

}

struct UpdateTextViewExternal: View {
    @ObservedObject var viewModel: MyViewController
    @State var showImagePicker: Bool = false
    @State private var image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    ZStack (alignment: .leading) {
                        
                        Rectangle().frame(width: min(CGFloat(self.viewModel.confidence ?? 0)*geometry.size.width, geometry.size.width), height: geometry.size.height/9)
                            .foregroundColor(Color("deeperGreen"))
                        .animation(.linear)
                        
                        Text(self.viewModel.classificationLabel ?? "default")
                                               .foregroundColor(.white)
                                               .font(.system(size: 40))
                                               .frame(width: geometry.size.width, height: geometry.size.height/9, alignment: .center)
                                           .background(Color("myGreen"))
    
                    }
                }
                .frame(width: geometry.size.width,
                       height: geometry.size.height/7, alignment: .center)
            }
        }
    }
}

struct MyRepresentable: UIViewControllerRepresentable{
    
    @State var controller: MyViewController
    func makeUIViewController(context: Context) -> MyViewController {
        return self.controller
    }
    func updateUIViewController(_ uiViewController: MyViewController, context: Context) {
        
    }
}

class MyViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {

    @Published var classificationLabel: String?
    var backCam: AVCaptureDevice?
    var frontCam: AVCaptureDevice?
    var captureDevice: AVCaptureDevice?
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var useCam: Bool = true
    var img: UIImage?
    var confidence: Float?
    var camImage: UIImage?
    var totalFrameCount = 0

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
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            blackView.alpha = 0
        }, completion: nil)  // shutter animation
        
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
       captureSession.stopRunning()
       previewLayer?.removeFromSuperlayer()
       if captureDevice == backCam{
           captureDevice = frontCam}
       else {
           captureDevice = backCam}
        captureSession = AVCaptureSession()
        guard let input = try? AVCaptureDeviceInput(device: self.captureDevice!) else {return}
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
        
        backCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first!
        frontCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first!
        captureDevice = backCam
        guard let input = try? AVCaptureDeviceInput(device: self.captureDevice!) else {return}
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
        totalFrameCount += 1
        if totalFrameCount % 20 != 0{ return } // skip frames to optimize
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    
        let curImg = UIImage(pixelBuffer: pixelBuffer)
        let rotatedImage = curImg!.rotate(radians: .pi/2)
        self.camImage = rotatedImage.crop(height: (previewLayer?.frame.height)!, width: (previewLayer?.frame.width)!)  // camImage is just the captured image without cropping
        
        guard let model = try? VNCoreMLModel(for: LobeModel().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishReq, err) in
            self.processClassifications(for: finishReq, error: err)
        }

        if self.useCam {  // crop images and send to model here
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
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(1)
                self.classificationLabel = topClassifications[0].identifier
                self.confidence = topClassifications[0].confidence
            }
        }
    }
}

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
        let newHeight = height/width * size.width
        var screenSize: CGSize  { .init(width: newWidth, height: newHeight)}
        guard let cgImage = cgImage?
            .cropping(to: .init(origin: .init(x: 0,
                                              y: ((size.height - newHeight)/2)),
                                size: screenSize)) else { return nil }
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: screenSize, format: format).image { _ in
            UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
            .draw(in: .init(origin: .zero, size: screenSize))
        }
    }
}

extension UIImage {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
