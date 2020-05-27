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

struct ContentView: View {
    var body: some View {
        MyRepresentable()
        
    }
}

class MyViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var classificationLabel: String?
    var myLabel: UILabel!
    
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
        self.myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        self.myLabel.center = CGPoint(x: 250, y: 1000)
        self.myLabel.textAlignment = .left
        self.myLabel.text = "test label"
        self.myLabel.textColor = .white
        self.myLabel.font = myLabel.font.withSize(50)
        self.view.addSubview(self.myLabel)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: MobileNet().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishReq, err) in
            self.processClassifications(for: finishReq, error: err)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
//        print(self.classificationLabel!)
        
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        if !(self.classificationLabel != nil) {
            self.classificationLabel = "begin"
        }
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
            self.myLabel.text = self.classificationLabel!
        }
    }
}

struct MyRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MyViewController {
        let controller = MyViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MyViewController, context: Context) {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
