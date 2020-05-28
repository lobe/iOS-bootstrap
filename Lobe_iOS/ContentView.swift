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
                        .aspectRatio(self.image!.size, contentMode: .fit)
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
                        UpdateTextViewExternal(viewModel: self.controller)
                        VStack{
                            Button(action: {
                                if self.image != nil {
                                    self.controller.changeStatus(useCam: true, img: self.image!)
                                    self.image = nil
                                }
                                self.controller.flipCamera()
                            }) {
                                Text("Switch Camera")
                               .font(.system(size: 20))
                           }
                            Spacer()
                           Button(action: {
                               self.showImagePicker = true
                           }) {
                               Text("Photo Library")
                               .font(.system(size: 20))
                           }
                        }
                    }
                .padding()
                .frame(width: geometry.size.width,
                      height: geometry.size.height/10, alignment: .bottomTrailing)
//                    .background(Color.purple)
                .sheet(isPresented: self.$showImagePicker) {
                    ImagePicker(image: self.$image, isShown: self.$showImagePicker, hehe: self.controller, sourceType: .photoLibrary)}
            }
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
                    Text(self.viewModel.classificationLabel ?? "default")
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                        .multilineTextAlignment(.leading)
                        .frame(width: geometry.size.width/3,
                            height: geometry.size.width/9, alignment: .bottomLeading)
            }
            .frame(width: geometry.size.width,
                   height: nil, alignment: .bottomLeading)
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
            }
        }
    }
}

struct MyRepresentable: UIViewControllerRepresentable {
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
