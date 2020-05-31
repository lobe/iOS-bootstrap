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

var useCam: Bool = true

struct ContentView: View {
    var controller: MyViewController = MyViewController()
    @State var showImagePicker: Bool = false
    @State private var image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
        
            VStack {
                if (self.image != nil) {
                    Image(uiImage: self.image!)
                        .resizable()
//                        .aspectRatio(self.image!.size, contentMode: .fit)
                } else {
                    MyRepresentable(controller: self.controller)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.top)
            
            VStack  {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        self.screenShotMethod()
                    }) {
                        Text("Screenshot")
                    }
                }.padding()
                
                UpdateTextViewExternal(viewModel: self.controller)
                HStack {
                            Button(action: {
                                self.showImagePicker = true
                            }) {
                                Text("Photo Lib")
                                 .frame(width: geometry.size.width/16, height: geometry.size.width/16)
                                    .multilineTextAlignment(.center)
                            }
                            .buttonStyle(RoundStyle())

                    
                            Button(action: {
                                self.controller.changeStatus(useCam: false, img: self.controller.camImage!)
                                self.image = self.controller.camImage
                            }) {
                                Text("Take Photo")
                                    .multilineTextAlignment(.center)
                                .frame(width: geometry.size.width/9, height: geometry.size.width/9)
                            }
                            .buttonStyle(RoundStyle())
                    
                            Button(action: {
                                if self.image != nil {
                                    self.controller.changeStatus(useCam: true, img: self.image!)
                                    self.image = nil
                                }
                                self.controller.flipCamera()
                            }) {
                                Text("Switch Cam")
                                    .multilineTextAlignment(.center)
                                    .frame(width: geometry.size.width/16, height: geometry.size.width/16)
                           }
                            .buttonStyle(RoundStyle())

                    }
                .padding()
                .frame(width: geometry.size.width,
                      height: nil, alignment: .bottom)
                .sheet(isPresented: self.$showImagePicker) {
                    ImagePicker(image: self.$image, isShown: self.$showImagePicker, controller: self.controller, sourceType: .photoLibrary)}
            }
        }
    }
    

    struct RoundStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.gray)
            .mask(Circle())
            .overlay(
                Circle().stroke(Color("lightGray"), lineWidth: 6))
            .shadow(radius: 10)
        }
    }
    
    func screenShotMethod() {
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
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
    
    func flipCamera() {
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
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let curImg = UIImage(pixelBuffer: pixelBuffer)
        let rotatedImage = curImg!.rotate(radians: .pi/2)
        self.camImage = rotatedImage
        
        guard let model = try? VNCoreMLModel(for: LobeModel().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishReq, err) in
            self.processClassifications(for: finishReq, error: err)
        }

        if useCam {
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        } else {
            try? VNImageRequestHandler(ciImage: CIImage(cgImage: (self.img?.cgImage!)!)).perform([request])
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
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let myImage = cgImage else {
            return nil
        }

        self.init(cgImage: myImage)
    }
}

extension UIImage {
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


struct MyRepresentable: UIViewControllerRepresentable{
    @State var controller: MyViewController
    func makeUIViewController(context: Context) -> MyViewController {
        return self.controller
    }
    func updateUIViewController(_ uiViewController: MyViewController, context: Context) {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
