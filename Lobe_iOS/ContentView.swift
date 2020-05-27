//
//  ContentView.swift
//  SwiftUICamera
//
//  Created by Mohammad Azam on 2/10/20.
//  Copyright © 2020 Mohammad Azam. All rights reserved.
//

import SwiftUI
import AVKit
import Vision

struct ContentView: View {
    var controller: MyViewController = MyViewController()
    var body: some View {
        VStack {
            MyRepresentable(controller: controller)
            UpdateTextViewExternal(viewModel: controller)
        }
    }
}

struct UpdateTextViewExternal: View {
    @ObservedObject var viewModel: MyViewController
    var body: some View {
        GeometryReader { geometry in
           VStack {
               VStack(alignment: .leading) {
                Spacer()
                   Text(self.viewModel.classificationLabel ?? "default")
                       .foregroundColor(.white)
                       .font(.system(size: 40))
                       .multilineTextAlignment(.leading)
               }
           }
           .padding()
           .frame(width: geometry.size.width,
                height: nil, alignment: .leading)
        }
    }
}

class MyViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {

    @Published var classificationLabel: String?
//    var myLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: MobileNet().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishReq, err) in
            self.processClassifications(for: finishReq, error: err)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
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
